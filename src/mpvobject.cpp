#include "mpvobject.h"

// std
#include <stdexcept>
#include <clocale>

// Qt
#include <QObject>
#include <QtGlobal>
#include <QOpenGLContext>

#include <QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQuick/QQuickView>

#include <QtQuick/QQuickFramebufferObject>
#include <QtGui/QOpenGLFramebufferObject>

#include <QtX11Extras/QX11Info>

#include <QDebug>

// libmpv
#include <mpv/client.h>
#include <mpv/render_gl.h>

// own
#include "qthelper.hpp"



//--- MpvRenderer
void* MpvRenderer::get_proc_address(void *ctx, const char *name) {
	(void)ctx;
	QOpenGLContext *glctx = QOpenGLContext::currentContext();
	if (!glctx)
		return nullptr;
	return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
}

MpvRenderer::MpvRenderer(const MpvObject *obj)
	: obj(obj)
	, mpv_gl(nullptr)
{

	// https://github.com/mpv-player/mpv/blob/master/libmpv/render_gl.h#L106
#if MPV_CLIENT_API_VERSION >= MPV_MAKE_VERSION(2, 0)
	mpv_opengl_init_params gl_init_params{
		get_proc_address,
		nullptr // get_proc_address_ctx
	};
#else
	mpv_opengl_init_params gl_init_params{
		get_proc_address,
		nullptr, // get_proc_address_ctx
		nullptr // extra_exts (deprecated)
	};
#endif

	mpv_render_param display{
		MPV_RENDER_PARAM_INVALID,
		nullptr
	};
	if (QX11Info::isPlatformX11()) {
		display.type = MPV_RENDER_PARAM_X11_DISPLAY;
		display.data = QX11Info::display();
	}
	mpv_render_param params[]{
		{ MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(MPV_RENDER_API_TYPE_OPENGL) },
		{ MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params },
		display,
		{ MPV_RENDER_PARAM_INVALID, nullptr }
	};

	if (mpv_render_context_create(&mpv_gl, obj->mpv, params) < 0)
		throw std::runtime_error("failed to initialize mpv GL context");

	mpv_render_context_set_update_callback(mpv_gl, MpvObject::on_update, (void *)obj);
}

MpvRenderer::~MpvRenderer() {
	if (mpv_gl)
		mpv_render_context_free(mpv_gl);

	mpv_terminate_destroy(obj->mpv);
}

void MpvRenderer::render() {
	QOpenGLFramebufferObject *fbo = framebufferObject();
	// fbo->bind();
	obj->window()->resetOpenGLState();

	// https://github.com/mpv-player/mpv/blob/master/libmpv/render_gl.h#L133
	mpv_opengl_fbo mpfbo{
		.fbo = static_cast<int>(fbo->handle()),
		.w = fbo->width(),
		.h = fbo->height(),
		.internal_format = 0 // 0=unknown
	};
	mpv_render_param params[] = {
		{ MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo },
		{ MPV_RENDER_PARAM_INVALID, nullptr }
	};
	mpv_render_context_render(mpv_gl, params);


	obj->window()->resetOpenGLState();
	// fbo->release();
}



//--- MpvObject
static void wakeup(void *ctx)
{
	QMetaObject::invokeMethod((MpvObject*)ctx, "onMpvEvents", Qt::QueuedConnection);
}

MpvObject::MpvObject(QQuickItem *parent)
	: QQuickFramebufferObject(parent)
	, m_enableAudio(true)
	, m_useHwdec(false)
	, m_duration(0)
	, m_position(0)
	, m_isPlaying(false)
{
	mpv = mpv_create();
	if (!mpv)
		throw std::runtime_error("could not create mpv context");

	mpv_set_option_string(mpv, "terminal", "yes");
	// mpv_set_option_string(mpv, "msg-level", "all=warn,ao/alsa=error");
	// mpv_set_option_string(mpv, "msg-level", "all=debug");

	//--- Hardware Decoding
	mpv::qt::set_option_variant(mpv, "hwdec-codecs", "all");

	if (mpv_initialize(mpv) < 0)
		throw std::runtime_error("could not initialize mpv context");


	mpv::qt::set_option_variant(mpv, "audio-client-name", "mpvz");

	mpv_request_log_messages(mpv, "terminal-default");

	//--- 60fps Interpolation
	mpv::qt::set_option_variant(mpv, "interpolation", "yes");
	mpv::qt::set_option_variant(mpv, "video-sync", "display-resample");
	// mpv::qt::set_option_variant(mpv, "vf", "lavfi=\"fps=fps=60:round=down\"");
	// mpv::qt::set_option_variant(mpv, "override-display-fps", "60");

	//--- ytdl 1080p max
	mpv::qt::set_option_variant(mpv, "ytdl-format", "ytdl-format=bestvideo[width<=?720]+bestaudio/best");


	mpv::qt::set_option_variant(mpv, "quiet", "yes");

	// Setup the callback that will make QtQuick update and redraw if there
	// is a new video frame. Use a queued connection: this makes sure the
	// doUpdate() function is run on the GUI thread.
	// * MpvRender binds mpv_gl update function to MpvObject::on_update
	// * MpvObject::on_update will emit MpvObject::mpvUpdated
	connect(this, &MpvObject::mpvUpdated,
			this, &MpvObject::doUpdate,
			Qt::QueuedConnection);

	WATCH_PROP_BOOL("idle-active")
	WATCH_PROP_BOOL("mute")
	WATCH_PROP_BOOL("pause")
	WATCH_PROP_BOOL("paused-for-cache")
	WATCH_PROP_BOOL("seekable")
	WATCH_PROP_INT("chapter")
	WATCH_PROP_INT("chapter-list/count")
	WATCH_PROP_INT("decoder-frame-drop-count")
	WATCH_PROP_INT("dheight")
	WATCH_PROP_INT("dwidth")
	WATCH_PROP_INT("estimated-frame-count")
	WATCH_PROP_INT("estimated-frame-number")
	WATCH_PROP_INT("frame-drop-count")
	WATCH_PROP_INT("playlist-pos")
	WATCH_PROP_INT("playlist/count")
	WATCH_PROP_INT("vo-delayed-frame-count")
	WATCH_PROP_INT("volume")
	WATCH_PROP_INT("vid")
	WATCH_PROP_INT("aid")
	WATCH_PROP_INT("sid")
	WATCH_PROP_INT("audio-params/channel-count")
	WATCH_PROP_INT("audio-params/samplerate")
	WATCH_PROP_INT("track-list/count")
	WATCH_PROP_INT("contrast")
	WATCH_PROP_INT("brightness")
	WATCH_PROP_INT("gamma")
	WATCH_PROP_INT("saturation")
	WATCH_PROP_INT("sub-margin-y")
	WATCH_PROP_DOUBLE("audio-bitrate")
	WATCH_PROP_DOUBLE("avsync")
	WATCH_PROP_DOUBLE("container-fps")
	WATCH_PROP_DOUBLE("demuxer-cache-duration")
	WATCH_PROP_DOUBLE("display-fps")
	WATCH_PROP_DOUBLE("duration")
	WATCH_PROP_DOUBLE("estimated-display-fps")
	WATCH_PROP_DOUBLE("estimated-vf-fps")
	WATCH_PROP_DOUBLE("fps")
	WATCH_PROP_DOUBLE("speed")
	WATCH_PROP_DOUBLE("time-pos")
	WATCH_PROP_DOUBLE("video-bitrate")
	WATCH_PROP_DOUBLE("video-params/aspect")
	WATCH_PROP_DOUBLE("video-out-params/aspect")
	WATCH_PROP_DOUBLE("window-scale")
	WATCH_PROP_DOUBLE("current-window-scale")
	WATCH_PROP_STRING("audio-codec")
	WATCH_PROP_STRING("audio-codec-name")
	WATCH_PROP_STRING("audio-params/format")
	WATCH_PROP_STRING("filename")
	WATCH_PROP_STRING("file-format")
	WATCH_PROP_STRING("file-size")
	WATCH_PROP_STRING("audio-format")
	WATCH_PROP_STRING("hwdec")
	WATCH_PROP_STRING("hwdec-current")
	WATCH_PROP_STRING("hwdec-interop")
	WATCH_PROP_STRING("media-title")
	WATCH_PROP_STRING("path")
	WATCH_PROP_STRING("video-codec")
	WATCH_PROP_STRING("video-format")
	WATCH_PROP_STRING("video-params/pixelformat")
	WATCH_PROP_STRING("video-out-params/pixelformat")
	WATCH_PROP_STRING("ytdl-format")
	WATCH_PROP_MAP("demuxer-cache-state")

	connect(this, &MpvObject::idleActiveChanged,
			this, &MpvObject::updateState);
	connect(this, &MpvObject::pausedChanged,
			this, &MpvObject::updateState);
	
	mpv_set_wakeup_callback(mpv, wakeup, this);
}

MpvObject::~MpvObject()
{

}

QQuickFramebufferObject::Renderer *MpvObject::createRenderer() const
{
	window()->setPersistentOpenGLContext(true);
	window()->setPersistentSceneGraph(true);
	return new MpvRenderer(this);
}

void MpvObject::on_update(void *ctx)
{
	MpvObject *self = (MpvObject *)ctx;
	emit self->mpvUpdated();
}

// connected to mpvUpdated(); signal makes sure it runs on the GUI thread
void MpvObject::doUpdate()
{
	update();
}

void MpvObject::command(const QVariant& params)
{
	mpv::qt::command(mpv, params);
}

void MpvObject::commandAsync(const QVariant& params)
{
	mpv::qt::command_async(mpv, params);
}

void MpvObject::setProperty(const QString& name, const QVariant& value)
{
	mpv::qt::set_property_variant(mpv, name, value);
}

QVariant MpvObject::getProperty(const QString &name) const
{
	return mpv::qt::get_property_variant(mpv, name);
}

void MpvObject::setOption(const QString& name, const QVariant& value)
{
	mpv::qt::set_option_variant(mpv, name, value);
}


void MpvObject::onMpvEvents()
{
	// Process all events, until the event queue is empty.
	while (mpv) {
		mpv_event *event = mpv_wait_event(mpv, 0);
		if (event->event_id == MPV_EVENT_NONE) {
			break;
		}
		handle_mpv_event(event);
	}
}

void MpvObject::logPropChange(mpv_event_property *prop)
{
	switch (prop->format) {
	case MPV_FORMAT_NONE:
		qDebug() << objectName() << "none" << prop->name << 0;
		break;
	case MPV_FORMAT_STRING:
		qDebug() << objectName() << "str " << prop->name << *(char**)prop->data;
		break;
	case MPV_FORMAT_FLAG:
		qDebug() << objectName() << "bool" << prop->name << *(bool *)prop->data;
		break;
	case MPV_FORMAT_INT64:
		qDebug() << objectName() << "int " << prop->name << *(int64_t *)prop->data;
		break;
	case MPV_FORMAT_DOUBLE:
		qDebug() << objectName() << "doub" << prop->name << *(double *)prop->data;
		break;
	case MPV_FORMAT_NODE_ARRAY:
		qDebug() << objectName() << "arr " << prop->name; // TODO
		break;
	case MPV_FORMAT_NODE_MAP:
		qDebug() << objectName() << "map " << prop->name; // TODO
		break;
	default:
		qDebug() << objectName() << "prop(format=" << prop->format << ")" << prop->name;
		break;
	}
}

void MpvObject::handle_mpv_event(mpv_event *event)
{
	// See: https://github.com/mpv-player/mpv/blob/master/libmpv/client.h
	// See: https://github.com/mpv-player/mpv/blob/master/player/lua.c#L471

	switch (event->event_id) {
	case MPV_EVENT_LOG_MESSAGE: {
		mpv_event_log_message *logData = (mpv_event_log_message *)event->data;
		Q_EMIT logMessage(
			QString(logData->prefix),
			QString(logData->level),
			QString(logData->text)
		);
		break;
	}
	case MPV_EVENT_START_FILE: {
		Q_EMIT fileStarted();
		break;
	}
	case MPV_EVENT_END_FILE: {
		mpv_event_end_file *eef = (mpv_event_end_file *)event->data;
		const char *reason;
		switch (eef->reason) {
		case MPV_END_FILE_REASON_EOF: reason = "eof"; break;
		case MPV_END_FILE_REASON_STOP: reason = "stop"; break;
		case MPV_END_FILE_REASON_QUIT: reason = "quit"; break;
		case MPV_END_FILE_REASON_ERROR: reason = "error"; break;
		case MPV_END_FILE_REASON_REDIRECT: reason = "redirect"; break;
		default:
			reason = "unknown";
		}
		Q_EMIT fileEnded(QString(reason));
		break;
	}
	case MPV_EVENT_FILE_LOADED: {
		Q_EMIT fileLoaded();
		break;
	}
	case MPV_EVENT_PROPERTY_CHANGE: {
		mpv_event_property *prop = (mpv_event_property *)event->data;
		// logPropChange(prop);

		if (prop->format == MPV_FORMAT_NONE) {
			if HANDLE_PROP_NONE("vid", vid)
			else if HANDLE_PROP_NONE("aid", aid)
			else if HANDLE_PROP_NONE("sid", sid)
			else if HANDLE_PROP_NONE("track-list/count", trackListCount)

		} else if (prop->format == MPV_FORMAT_DOUBLE) {
			if (strcmp(prop->name, "time-pos") == 0) {
				double time = *(double *)prop->data;
				m_position = time;
				Q_EMIT positionChanged(time);
			} else if (strcmp(prop->name, "duration") == 0) {
				double time = *(double *)prop->data;
				m_duration = time;
				Q_EMIT durationChanged(time);
			}
			else if HANDLE_PROP_DOUBLE("audio-bitrate", audioBitrate)
			else if HANDLE_PROP_DOUBLE("avsync", avsync)
			else if HANDLE_PROP_DOUBLE("container-fps", containerFps)
			else if HANDLE_PROP_DOUBLE("demuxer-cache-duration", demuxerCacheDuration)
			else if HANDLE_PROP_DOUBLE("display-fps", displayFps)
			else if HANDLE_PROP_DOUBLE("estimated-display-fps", estimatedDisplayFps)
			else if HANDLE_PROP_DOUBLE("estimated-vf-fps", estimatedVfFps)
			else if HANDLE_PROP_DOUBLE("fps", fps)
			else if HANDLE_PROP_DOUBLE("speed", speed)
			else if HANDLE_PROP_DOUBLE("video-bitrate", videoBitrate)
			else if HANDLE_PROP_DOUBLE("video-params/aspect", videoParamsAspect)
			else if HANDLE_PROP_DOUBLE("video-out-params/aspect", videoOutParamsAspect)
			else if HANDLE_PROP_DOUBLE("window-scale", windowScale)
			else if HANDLE_PROP_DOUBLE("current-window-scale", currentWindowScale)

		} else if (prop->format == MPV_FORMAT_FLAG) {
			if HANDLE_PROP_BOOL("idle-active", idleActive)
			else if HANDLE_PROP_BOOL("mute", muted)
			else if HANDLE_PROP_BOOL("pause", paused)
			else if HANDLE_PROP_BOOL("paused-for-cache", pausedForCache)
			else if HANDLE_PROP_BOOL("seekable", seekable)

		} else if (prop->format == MPV_FORMAT_STRING) {
			if HANDLE_PROP_STRING("audio-codec", audioCodec)
			else if HANDLE_PROP_STRING("audio-codec-name", audioCodecName)
			else if HANDLE_PROP_STRING("audio-params/format", audioParamsFormat)
			else if HANDLE_PROP_STRING("filename", filename)
			else if HANDLE_PROP_STRING("file-format", fileFormat)
			else if HANDLE_PROP_STRING("file-size", fileSize)
			else if HANDLE_PROP_STRING("audio-format", audioFormat)
			else if HANDLE_PROP_STRING("hwdec", hwdec)
			else if HANDLE_PROP_STRING("hwdec-current", hwdecCurrent)
			else if HANDLE_PROP_STRING("hwdec-interop", hwdecInterop)
			else if HANDLE_PROP_STRING("media-title", mediaTitle)
			else if HANDLE_PROP_STRING("path", path)
			else if HANDLE_PROP_STRING("video-codec", videoCodec)
			else if HANDLE_PROP_STRING("video-format", videoFormat)
			else if HANDLE_PROP_STRING("video-params/pixelformat", videoParamsPixelformat)
			else if HANDLE_PROP_STRING("video-out-params/pixelformat", videoOutParamsPixelformat)
			else if HANDLE_PROP_STRING("ytdl-format", ytdlFormat)


		} else if (prop->format == MPV_FORMAT_INT64) {
			if HANDLE_PROP_INT("chapter", chapter)
			else if HANDLE_PROP_INT("chapter-list/count", chapterListCount)
			else if HANDLE_PROP_INT("decoder-frame-drop-count", decoderFrameDropCount)
			else if HANDLE_PROP_INT("dwidth", dwidth)
			else if HANDLE_PROP_INT("dheight", dheight)
			else if HANDLE_PROP_INT("estimated-frame-count", estimatedFrameCount)
			else if HANDLE_PROP_INT("estimated-frame-number", estimatedFrameNumber)
			else if HANDLE_PROP_INT("frame-drop-count", frameDropCount)
			else if HANDLE_PROP_INT("playlist-pos", playlistPos)
			else if HANDLE_PROP_INT("playlist/count", playlistCount)
			else if HANDLE_PROP_INT("vo-delayed-frame-count", voDelayedFrameCount)
			else if HANDLE_PROP_INT("volume", volume)
			else if HANDLE_PROP_INT("vid", vid)
			else if HANDLE_PROP_INT("aid", aid)
			else if HANDLE_PROP_INT("sid", sid)
			else if HANDLE_PROP_INT("audio-params/channel-count", audioParamsChannelCount)
			else if HANDLE_PROP_INT("audio-params/samplerate", audioParamsSampleRate)
			else if HANDLE_PROP_INT("track-list/count", trackListCount)
			else if HANDLE_PROP_INT("contrast", contrast)
			else if HANDLE_PROP_INT("brightness", brightness)
			else if HANDLE_PROP_INT("gamma", gamma)
			else if HANDLE_PROP_INT("saturation", saturation)
			else if HANDLE_PROP_INT("sub-margin-y", subMarginY)


		} else if (prop->format == MPV_FORMAT_NODE_MAP) {
			if HANDLE_PROP_MAP("demuxer-cache-state", demuxerCacheState)
		}
		break;
	}
	default: ;
		// Ignore uninteresting or unknown events.
	}
}

void MpvObject::play()
{
	// qDebug() << "play";
	if (idleActive() && playlistCount() >= 1) { // File has finished playing.
		// qDebug() << "\treload";
		set_playlistPos(playlistPos()); // Reload and play file again.
	}
	if (!isPlaying()) {
		// qDebug() << "\t!isPlaying";
		set_paused(false);
	}
}

void MpvObject::pause()
{
	// qDebug() << "pause";
	if (isPlaying()) {
		// qDebug() << "!isPlaying";
		set_paused(true);
	}
}

void MpvObject::playPause()
{
	if (isPlaying()) {
		pause();
	} else {
		play();
	}
}

void MpvObject::stop()
{
	command(QVariantList() << "stop" << "keep-playlist");
}

void MpvObject::stepBackward()
{
	command(QVariantList() << "frame-back-step");
}

void MpvObject::stepForward()
{
	command(QVariantList() << "frame-step");
}

void MpvObject::seek(double pos)
{
	// qDebug() << "seek" << pos;
	pos = qMax(0.0, qMin(pos, m_duration));
	commandAsync(QVariantList() << "seek" << pos << "absolute");
}

void MpvObject::loadFile(QVariant urls)
{
	command(QVariantList() << "loadfile" << urls);
}

void MpvObject::subAdd(QVariant urls)
{
	command(QVariantList() << "sub-add" << urls);
}


void MpvObject::updateState()
{
	bool isNowPlaying = !idleActive() && !paused();
	if (m_isPlaying != isNowPlaying) {
		m_isPlaying = isNowPlaying;
		emit isPlayingChanged(m_isPlaying);
	}
}


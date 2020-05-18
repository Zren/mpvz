#include "mpvobject.h"

#include <stdexcept>
#include <clocale>

#include <QObject>
#include <QtGlobal>
#include <QOpenGLContext>

#include <QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQuick/QQuickView>

#include <QtQuick/QQuickFramebufferObject>
#include <QtGui/QOpenGLFramebufferObject>

#include <QDebug>

class MpvRenderer : public QQuickFramebufferObject::Renderer
{
	static void *get_proc_address(void *ctx, const char *name) {
		(void)ctx;
		QOpenGLContext *glctx = QOpenGLContext::currentContext();
		if (!glctx)
			return NULL;
		return (void *)glctx->getProcAddress(QByteArray(name));
	}

public:
	MpvRenderer(const MpvObject *obj)
		: mpv(obj->mpv)
		, window(obj->window())
		, mpv_gl(obj->mpv_gl)
	{
		int r = mpv_opengl_cb_init_gl(mpv_gl, NULL, get_proc_address, NULL);
		if (r < 0)
			throw std::runtime_error("could not initialize OpenGL");
	}

	virtual ~MpvRenderer() {
		// Until this call is done, we need to make sure the player remains
		// alive. This is done implicitly with the mpv::qt::Handle instance
		// in this class.
		mpv_opengl_cb_uninit_gl(mpv_gl);
	}

	void render() {
		QOpenGLFramebufferObject *fbo = framebufferObject();
		// fbo->bind();
		window->resetOpenGLState();
		mpv_opengl_cb_draw(mpv_gl, fbo->handle(), fbo->width(), fbo->height());
		window->resetOpenGLState();
		// fbo->release();
	}

private:
	mpv::qt::Handle mpv;
	QQuickWindow *window;
	mpv_opengl_cb_context *mpv_gl;
};




static void wakeup(void *ctx)
{
	QMetaObject::invokeMethod((MpvObject*)ctx, "on_mpv_events", Qt::QueuedConnection);
}

MpvObject::MpvObject(QQuickItem * parent)
	: QQuickFramebufferObject(parent)
	, mpv_gl(0)
	, m_enableAudio(true)
	, m_duration(0)
	, m_position(0)
	, m_isPlaying(false)
{
	mpv = mpv::qt::Handle::FromRawHandle(mpv_create());
	if (!mpv)
		throw std::runtime_error("could not create mpv context");

	mpv_set_option_string(mpv, "terminal", "yes");
	mpv_set_option_string(mpv, "msg-level", "all=warn,ao/alsa=error"); // all=no OR all=v
	// mpv_set_option_string(mpv, "msg-level", "all=debug");

	if (mpv_initialize(mpv) < 0)
		throw std::runtime_error("could not initialize mpv context");


	mpv::qt::set_option_variant(mpv, "audio-client-name", "mpvz");

	// Make use of the MPV_SUB_API_OPENGL_CB API.
	// mpv::qt::set_option_variant(mpv, "vo", "opengl-cb");

	// Not sure how
	mpv::qt::set_option_variant(mpv, "vo", "opengl-cb:interpolation");
	mpv::qt::set_option_variant(mpv, "video-syn", "display-resample");
	// mpv::qt::set_option_variant(mpv, "vf", "lavfi=\"fps=fps=60:round=down\"");

	// Request hw decoding by default
	// mpv::qt::set_option_variant(mpv, "hwdec", "auto");
	// mpv::qt::set_option_variant(mpv, "hwdec-codecs", "all");
	// mpv::qt::set_option_variant(mpv, "hwdec", "auto-copy");

	// Testing
	// mpv::qt::set_option_variant(mpv, "vo", "vaapi");
	// mpv::qt::set_option_variant(mpv, "hwdec", "vaapi-copy");
	// mpv::qt::set_option_variant(mpv, "hwdec", "h264-vaapi-copy");

	// mpv::qt::set_option_variant(mpv, "aid", "no");
	// mpv::qt::set_option_variant(mpv, "sid", "no");
	// mpv::qt::set_option_variant(mpv, "audio-file-auto", "no");
	// mpv::qt::set_option_variant(mpv, "sub-auto", "no");
	// mpv::qt::set_option_variant(mpv, "osd-level", "0");
	// mpv::qt::set_option_variant(mpv, "quiet", "yes");
	// mpv::qt::set_option_variant(mpv, "title", "\"\"");
	// mpv::qt::set_option_variant(mpv, "audio-pitch-correction", "no");
	// mpv::qt::set_option_variant(mpv, "pause", "yes");
	// mpv::qt::set_option_variant(mpv, "keep-open", "always");
	// mpv::qt::set_option_variant(mpv, "vd-lavc-skiploopfilter", "all");
	// mpv::qt::set_option_variant(mpv, "use-text-osd", "no");
	// mpv::qt::set_option_variant(mpv, "audio-display", "no");
	// mpv::qt::set_option_variant(mpv, "access-references", "no");
	// mpv::qt::set_option_variant(mpv, "frames", "1");


	// Setup the callback that will make QtQuick update and redraw if there
	// is a new video frame. Use a queued connection: this makes sure the
	// doUpdate() function is run on the GUI thread.
	mpv_gl = (mpv_opengl_cb_context *)mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB);
	if (!mpv_gl)
		throw std::runtime_error("OpenGL not compiled in");
	mpv_opengl_cb_set_update_callback(mpv_gl, MpvObject::on_update, (void *)this);
	connect(this, &MpvObject::mpvUpdated, this, &MpvObject::doUpdate,
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
	WATCH_PROP_INT("contrast")
	WATCH_PROP_INT("brightness")
	WATCH_PROP_INT("gamma")
	WATCH_PROP_INT("saturation")
	WATCH_PROP_DOUBLE("audio-bitrate")
	WATCH_PROP_DOUBLE("avsync")
	WATCH_PROP_DOUBLE("container-fps")
	WATCH_PROP_DOUBLE("duration")
	WATCH_PROP_DOUBLE("estimated-display-fps")
	WATCH_PROP_DOUBLE("estimated-vf-fps")
	WATCH_PROP_DOUBLE("fps")
	WATCH_PROP_DOUBLE("speed")
	WATCH_PROP_DOUBLE("time-pos")
	WATCH_PROP_DOUBLE("video-bitrate")
	WATCH_PROP_STRING("audio-codec")
	WATCH_PROP_STRING("audio-codec-name")
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

	connect(this, &MpvObject::idleActiveChanged,
			this, &MpvObject::updateState);
	connect(this, &MpvObject::pausedChanged,
			this, &MpvObject::updateState);
	
	mpv_set_wakeup_callback(mpv, wakeup, this);
}

MpvObject::~MpvObject()
{
	if (mpv_gl)
		mpv_opengl_cb_set_update_callback(mpv_gl, NULL, NULL);
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
	mpv::qt::command_variant(mpv, params);
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


void MpvObject::on_mpv_events()
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

void MpvObject::handle_mpv_event(mpv_event *event)
{
	// See: https://github.com/mpv-player/mpv/blob/master/libmpv/client.h
	// See: https://github.com/mpv-player/mpv/blob/master/player/lua.c#L471

	switch (event->event_id) {
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

		if (prop->format == MPV_FORMAT_NONE) {
			if HANDLE_PROP_INT("vid", vid)
			else if HANDLE_PROP_INT("aid", aid)
			else if HANDLE_PROP_INT("sid", sid)

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
			else if HANDLE_PROP_DOUBLE("estimated-display-fps", estimatedDisplayFps)
			else if HANDLE_PROP_DOUBLE("estimated-vf-fps", estimatedVfFps)
			else if HANDLE_PROP_DOUBLE("fps", fps)
			else if HANDLE_PROP_DOUBLE("speed", speed)
			else if HANDLE_PROP_DOUBLE("video-bitrate", videoBitrate)

		} else if (prop->format == MPV_FORMAT_FLAG) {
			if HANDLE_PROP_BOOL("idle-active", idleActive)
			else if HANDLE_PROP_BOOL("mute", muted)
			else if HANDLE_PROP_BOOL("pause", paused)
			else if HANDLE_PROP_BOOL("paused-for-cache", pausedForCache)
			else if HANDLE_PROP_BOOL("seekable", seekable)

		} else if (prop->format == MPV_FORMAT_STRING) {
			if HANDLE_PROP_STRING("audio-codec", audioCodec)
			else if HANDLE_PROP_STRING("audio-codec-name", audioCodecName)
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
			else if HANDLE_PROP_INT("contrast", contrast)
			else if HANDLE_PROP_INT("brightness", brightness)
			else if HANDLE_PROP_INT("gamma", gamma)
			else if HANDLE_PROP_INT("saturation", saturation)
		}
		break;
	}
	default: ;
		// Ignore uninteresting or unknown events.
	}
}

void MpvObject::play()
{
	qDebug() << "play";
	if (idleActive() && playlistCount() >= 1) { // File has finished playing.
		qDebug() << "\treload";
		set_playlistPos(playlistPos()); // Reload and play file again.
	}
	if (!isPlaying()) {
		qDebug() << "\t!isPlaying";
		set_paused(false);
	}
}

void MpvObject::pause()
{
	qDebug() << "pause";
	if (isPlaying()) {
		qDebug() << "!isPlaying";
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

void MpvObject::seek(double pos)
{
	qDebug() << "seek" << pos;
	pos = qMax(0.0, qMin(pos, m_duration));
	command(QVariantList() << "seek" << pos << "absolute");
}

void MpvObject::loadFile(QVariant urls)
{
	command(QVariantList() << "loadfile" << urls);
}


void MpvObject::updateState()
{
	bool isNowPlaying = !idleActive() && !paused();
	if (m_isPlaying != isNowPlaying) {
		m_isPlaying = isNowPlaying;
		emit isPlayingChanged(m_isPlaying);
	}
}


#include "mpvobject.h"

#include <stdexcept>
#include <clocale>

#include <QObject>
#include <QtGlobal>
#include <QOpenGLContext>

#include <QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQuick/QQuickView>

static void *get_proc_address(void *ctx, const char *name) {
	(void)ctx;
	QOpenGLContext *glctx = QOpenGLContext::currentContext();
	if (!glctx)
		return NULL;
	return (void *)glctx->getProcAddress(QByteArray(name));
}

MpvRenderer::MpvRenderer(mpv::qt::Handle a_mpv, mpv_opengl_cb_context *a_mpv_gl)
	: mpv(a_mpv)
	, mpv_gl(a_mpv_gl)
	, window(0)
	, size()
{
	int r = mpv_opengl_cb_init_gl(mpv_gl, NULL, get_proc_address, NULL);
	if (r < 0)
		throw std::runtime_error("could not initialize OpenGL");
}

MpvRenderer::~MpvRenderer()
{
	// Until this call is done, we need to make sure the player remains
	// alive. This is done implicitly with the mpv::qt::Handle instance
	// in this class.
	mpv_opengl_cb_uninit_gl(mpv_gl);
}

void MpvRenderer::paint()
{
	window->resetOpenGLState();

	// This uses 0 as framebuffer, which indicates that mpv will render directly
	// to the frontbuffer. Note that mpv will always switch framebuffers
	// explicitly. Some QWindow setups (such as using QQuickWidget) actually
	// want you to render into a FBO in the beforeRendering() signal, and this
	// code won't work there.
	// The negation is used for rendering with OpenGL's flipped coordinates.
	mpv_opengl_cb_draw(mpv_gl, 0, size.width(), -size.height());

	window->resetOpenGLState();
}

static void wakeup(void *ctx)
{
	QMetaObject::invokeMethod((MpvObject*)ctx, "on_mpv_events", Qt::QueuedConnection);
}

MpvObject::MpvObject(QQuickItem * parent)
	: QQuickItem(parent)
	, mpv_gl(0)
	, renderer(0)
	, killOnce(false)
	, m_duration(0)
	, m_position(0)
{
	mpv = mpv::qt::Handle::FromRawHandle(mpv_create());
	if (!mpv)
		throw std::runtime_error("could not create mpv context");

	mpv_set_option_string(mpv, "terminal", "yes");
	mpv_set_option_string(mpv, "msg-level", "all=warn,ao/alsa=error"); // all=no OR all=v

	if (mpv_initialize(mpv) < 0)
		throw std::runtime_error("could not initialize mpv context");


	mpv::qt::set_option_variant(mpv, "audio-client-name", "mpvz");

	// Make use of the MPV_SUB_API_OPENGL_CB API.
	mpv::qt::set_option_variant(mpv, "vo", "opengl-cb");

	// Request hw decoding, just for testing.
	mpv::qt::set_option_variant(mpv, "hwdec", "auto");

	mpv::qt::set_option_variant(mpv, "vf", "lavfi=\"fps=fps=60:round=down\"");

	// Setup the callback that will make QtQuick update and redraw if there
	// is a new video frame. Use a queued connection: this makes sure the
	// doUpdate() function is run on the GUI thread.
	mpv_gl = (mpv_opengl_cb_context *)mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB);
	if (!mpv_gl)
		throw std::runtime_error("OpenGL not compiled in");
	mpv_opengl_cb_set_update_callback(mpv_gl, MpvObject::on_update, (void *)this);
	connect(this, &MpvObject::mpvUpdated, this, &MpvObject::doUpdate,
			Qt::QueuedConnection);

	connect(this, &QQuickItem::windowChanged,
			this, &MpvObject::handleWindowChanged);

	mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
	mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
	mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG);
	mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
	mpv_observe_property(mpv, 0, "hwdec-current", MPV_FORMAT_STRING);
	
	mpv_set_wakeup_callback(mpv, wakeup, this);
}

MpvObject::~MpvObject()
{
	if (mpv_gl)
		mpv_opengl_cb_set_update_callback(mpv_gl, NULL, NULL);
}

void MpvObject::handleWindowChanged(QQuickWindow *win)
{
	if (!win)
		return;
	connect(win, &QQuickWindow::beforeSynchronizing,
			this, &MpvObject::sync, Qt::DirectConnection);
	connect(win, &QQuickWindow::sceneGraphInvalidated,
			this, &MpvObject::cleanup, Qt::DirectConnection);
	connect(win, &QQuickWindow::frameSwapped,
			this, &MpvObject::swapped, Qt::DirectConnection);
	win->setClearBeforeRendering(false);
}

void MpvObject::sync()
{
	if (killOnce)
		cleanup();
	killOnce = false;

	if (!renderer) {
		renderer = new MpvRenderer(mpv, mpv_gl);
		connect(window(), &QQuickWindow::beforeRendering,
				renderer, &MpvRenderer::paint, Qt::DirectConnection);
	}
	renderer->window = window();
	renderer->size = window()->size() * window()->devicePixelRatio();
}

void MpvObject::swapped()
{
	mpv_opengl_cb_report_flip(mpv_gl, 0);
}

void MpvObject::cleanup()
{
	if (renderer) {
		delete renderer;
		renderer = 0;
	}
}

void MpvObject::on_update(void *ctx)
{
	MpvObject *self = (MpvObject *)ctx;
	emit self->mpvUpdated();
}

// connected to mpvUpdated(); signal makes sure it runs on the GUI thread
void MpvObject::doUpdate()
{
	window()->update();
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

void MpvObject::reinitRenderer()
{
	// Don't make it stop playback if the VO dies.
	mpv_set_option_string(mpv, "stop-playback-on-init-failure", "no");
	// Make it recreate the renderer, which involves calling
	// mpv_opengl_cb_uninit_gl() (which is the thing we want to test).
	killOnce = true;
	window()->update();
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

	switch (event->event_id) {
	case MPV_EVENT_PROPERTY_CHANGE: {
		mpv_event_property *prop = (mpv_event_property *)event->data;
		if (strcmp(prop->name, "time-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
			double time = *(double *)prop->data;
			m_position = time;
			Q_EMIT positionChanged(time);
		} else if (strcmp(prop->name, "duration") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
			double time = *(double *)prop->data;
			m_duration = time;
			Q_EMIT durationChanged(time);
		} else if (strcmp(prop->name, "pause") == 0 && prop->format == MPV_FORMAT_FLAG) {
			bool value = *(bool *)prop->data;
			m_paused = value;
			Q_EMIT pausedChanged(value);
		} else if (prop->format == MPV_FORMAT_STRING) {
			if (strcmp(prop->name, "media-title") == 0) {
				QString value = getProperty("media-title").toString();
				m_mediaTitle = value;
				Q_EMIT mediaTitleChanged(value);
			} else if (strcmp(prop->name, "hwdec-current") == 0) {
				QString value = getProperty("hwdec-current").toString();
				m_hwdecCurrent = value;
				Q_EMIT hwdecCurrentChanged(value);
			}
		}
		break;
	}
	default: ;
		// Ignore uninteresting or unknown events.
	}
}

void MpvObject::play()
{
	if (m_paused) {
		setProperty("pause", false);
	}
}

void MpvObject::pause()
{
	if (!m_paused) {
		setProperty("pause", true);
	}
}

void MpvObject::playPause()
{
	setProperty("pause", !m_paused);
}

void MpvObject::seek(double pos)
{
	command(QVariantList() << "seek" << pos << "absolute");
}

void MpvObject::loadFile(QVariant urls)
{
	command(QVariantList() << "loadfile" << urls);
}

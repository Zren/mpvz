#ifndef MPVRENDERER_H_
#define MPVRENDERER_H_

#include <QtQuick/QQuickItem>

#include <mpv/client.h>
#include <mpv/opengl_cb.h>
#include <mpv/qthelper.hpp>

class MpvRenderer : public QObject
{
	Q_OBJECT
	mpv::qt::Handle mpv;
	mpv_opengl_cb_context *mpv_gl;
	QQuickWindow *window;
	QSize size;

	friend class MpvObject;
public:
	MpvRenderer(mpv::qt::Handle a_mpv, mpv_opengl_cb_context *a_mpv_gl);
	virtual ~MpvRenderer();
public slots:
	void paint();
};

class MpvObject : public QQuickItem
{
	Q_OBJECT

	mpv::qt::Handle mpv;
	mpv_opengl_cb_context *mpv_gl;
	MpvRenderer *renderer;
	bool killOnce;


	Q_PROPERTY(bool duration READ duration NOTIFY durationChanged)
	Q_PROPERTY(bool position READ position NOTIFY positionChanged)

public:
	MpvObject(QQuickItem * parent = 0);
	virtual ~MpvObject();
public slots:
	void command(const QVariant& params);
	void sync();
	void swapped();
	void cleanup();
	void reinitRenderer();

	bool duration() const { return m_duration; }
	bool position() const { return m_position; }
signals:
    void durationChanged(double value); // Unit: seconds
    void positionChanged(double value); // Unit: seconds
	void mpvUpdated();
private slots:
    void on_mpv_events();
	void doUpdate();
	void handleWindowChanged(QQuickWindow *win);
private:
    void handle_mpv_event(mpv_event *event);
	static void on_update(void *ctx);

	double m_duration;
	double m_position;
};

#endif

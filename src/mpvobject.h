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


	Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
	Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
	Q_PROPERTY(double position READ position NOTIFY positionChanged)
	Q_PROPERTY(QString mediaTitle READ mediaTitle NOTIFY mediaTitleChanged)
	Q_PROPERTY(QString hwdecCurrent READ hwdecCurrent NOTIFY hwdecCurrentChanged)

public:
	MpvObject(QQuickItem * parent = 0);
	virtual ~MpvObject();

	void setProperty(const QString& name, const QVariant& value);
	QVariant getProperty(const QString& name) const;


public slots:
	void command(const QVariant& params);
	void sync();
	void swapped();
	void cleanup();
	void reinitRenderer();

	void playPause();
	void play();
	void pause();
	void seek(double pos);
	void loadFile(QVariant urls);

	bool paused() const { return m_paused; }
	double duration() const { return m_duration; }
	double position() const { return m_position; }
	QString mediaTitle() const { return m_mediaTitle; }
	QString hwdecCurrent() const { return m_hwdecCurrent; }

signals:
	void pausedChanged(bool value);
	void durationChanged(double value); // Unit: seconds
	void positionChanged(double value); // Unit: seconds
	void mediaTitleChanged(QString value);
	void hwdecCurrentChanged(QString value);

	void mpvUpdated();

private slots:
	void on_mpv_events();
	void doUpdate();
	void handleWindowChanged(QQuickWindow *win);

private:
	void handle_mpv_event(mpv_event *event);
	static void on_update(void *ctx);

	bool m_paused;
	double m_duration;
	double m_position;
	QString m_mediaTitle;
	QString m_hwdecCurrent;
};

#endif

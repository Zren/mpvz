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
	Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
	Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
	Q_PROPERTY(int chapter READ chapter NOTIFY chapterChanged)
	Q_PROPERTY(int chapterListCount READ chapterListCount NOTIFY chapterListCountChanged)

public:
	MpvObject(QQuickItem * parent = 0);
	virtual ~MpvObject();

	void setProperty(const QString& name, const QVariant& value);
	QVariant getProperty(const QString& name) const;

	Q_INVOKABLE QString getChapterTitle(int chapterIndex) const { return getProperty(QString("chapter-list/%1/title").arg(chapterIndex)).toString(); }
	Q_INVOKABLE double getChapterTime(int chapterIndex) const { return getProperty(QString("chapter-list/%1/time").arg(chapterIndex)).toDouble(); }

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
	int volume() const { return getProperty("volume").toInt(); }
	bool muted() const { return getProperty("mute").toBool(); }

	int chapter() const { return getProperty("chapter").toInt(); }
	int chapterListCount() const { return getProperty("chapter-list/count").toInt(); } // OR "chapters"

	void setVolume(int value) { setProperty("volume", value); }
	void setMuted(bool value) { setProperty("mute", value); }

signals:
	void pausedChanged(bool value);
	void durationChanged(double value); // Unit: seconds
	void positionChanged(double value); // Unit: seconds
	void mediaTitleChanged(QString value);
	void hwdecCurrentChanged(QString value);
	void volumeChanged(int64_t value);
	void mutedChanged(bool value);
	void chapterChanged(int value);
	void chapterListCountChanged(int value);

	void mpvUpdated();

	void fileStarted();
	void fileEnded();
	void fileLoaded();

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

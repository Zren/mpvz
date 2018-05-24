#ifndef MPVRENDERER_H_
#define MPVRENDERER_H_

#include "mpvhelpers.h"

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

	Q_PROPERTY(bool enableAudio READ enableAudio WRITE setEnableAudio NOTIFY enableAudioChanged)

	WRITABLE_PROP_BOOL("mute", muted)
	READONLY_PROP_BOOL("pause", paused)
	READONLY_PROP_BOOL("paused-for-cache", pausedForCache)
	READONLY_PROP_BOOL("seekable", seekable)
	READONLY_PROP_INT("chapter", chapter)
	READONLY_PROP_INT("chapter-list/count", chapterListCount) // OR "chapters"
	READONLY_PROP_INT("decoder-frame-drop-count", decoderFrameDropCount)
	READONLY_PROP_INT("dheight", dheight)
	READONLY_PROP_INT("dwidth", dwidth)
	WRITABLE_PROP_INT("estimated-frame-count", estimatedFrameCount)
	WRITABLE_PROP_INT("estimated-frame-number", estimatedFrameNumber)
	READONLY_PROP_INT("frame-drop-count", frameDropCount)
	WRITABLE_PROP_INT("playlist-pos", playlistPos)
	READONLY_PROP_INT("playlist/count", playlistCount)
	WRITABLE_PROP_INT("vo-delayed-frame-count", voDelayedFrameCount)
	WRITABLE_PROP_INT("volume", volume)
	READONLY_PROP_DOUBLE("audio-bitrate", audioBitrate)
	READONLY_PROP_DOUBLE("avsync", avsync)
	READONLY_PROP_DOUBLE("container-fps", containerFps)
	READONLY_PROP_DOUBLE("estimated-display-fps", estimatedDisplayFps)
	READONLY_PROP_DOUBLE("estimated-vf-fps", estimatedVfFps)
	READONLY_PROP_DOUBLE("fps", fps) // Deprecated, use "container-fps"
	WRITABLE_PROP_DOUBLE("speed", speed)
	READONLY_PROP_DOUBLE("video-bitrate", videoBitrate)
	READONLY_PROP_STRING("audio-codec", audioCodec)
	READONLY_PROP_STRING("audio-codec-name", audioCodecName)
	READONLY_PROP_STRING("filename", filename)
	READONLY_PROP_STRING("file-format", fileFormat)
	READONLY_PROP_STRING("file-size", fileSize)
	READONLY_PROP_STRING("format", format)
	READONLY_PROP_STRING("hwdec", hwdec)
	READONLY_PROP_STRING("hwdec-current", hwdecCurrent)
	READONLY_PROP_STRING("hwdec-interop", hwdecInterop)
	READONLY_PROP_STRING("media-title", mediaTitle)
	READONLY_PROP_STRING("path", path)
	READONLY_PROP_STRING("video-codec", videoCodec)
	READONLY_PROP_STRING("video-format", videoFormat)

public:
	Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
	Q_PROPERTY(double position READ position NOTIFY positionChanged)

public:
	MpvObject(QQuickItem * parent = 0);
	virtual ~MpvObject();

	Q_INVOKABLE void setProperty(const QString& name, const QVariant& value);
	Q_INVOKABLE QVariant getProperty(const QString& name) const;
	Q_INVOKABLE void setOption(const QString& name, const QVariant& value);

	Q_INVOKABLE QString getPlaylistFilename(int playlistIndex) const { return getProperty(QString("playlist/%1/filename").arg(playlistIndex)).toString(); }
	Q_INVOKABLE QString getPlaylistTitle(int playlistIndex) const { return getProperty(QString("playlist/%1/title").arg(playlistIndex)).toString(); }
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

	bool enableAudio() const { return m_enableAudio; }
	void setEnableAudio(bool value) {
		m_enableAudio = value;
		if (!m_enableAudio) {
			mpv::qt::set_option_variant(mpv, "ao", "null");
		}
	}

	double duration() const { return m_duration; }
	double position() const { return m_position; }

signals:
	void enableAudioChanged(bool value);

	void durationChanged(double value); // Unit: seconds
	void positionChanged(double value); // Unit: seconds

	void mpvUpdated();

	void fileStarted();
	void fileEnded(QString reason);
	void fileLoaded();

private slots:
	void on_mpv_events();
	void doUpdate();
	void handleWindowChanged(QQuickWindow *win);

private:
	void handle_mpv_event(mpv_event *event);
	static void on_update(void *ctx);

	bool m_enableAudio;
	double m_duration;
	double m_position;
};

#endif

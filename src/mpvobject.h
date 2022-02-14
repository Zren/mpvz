#pragma once

#include "mpvhelpers.h"

// Qt
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickFramebufferObject>

// libmpv
#include <mpv/client.h>
#include <mpv/render_gl.h>

// own
#include "qthelper.hpp"
class MpvObject;
class MpvRenderer;



class MpvRenderer : public QQuickFramebufferObject::Renderer
{
	static void* get_proc_address(void *ctx, const char *name);

public:
	MpvRenderer(const MpvObject *obj);
	virtual ~MpvRenderer();

	void render();

private:
	const MpvObject *obj;
	mpv_render_context *mpv_gl;
};



class MpvObject : public QQuickFramebufferObject
{
	Q_OBJECT

	friend class MpvRenderer;

	Q_PROPERTY(bool enableAudio READ enableAudio WRITE setEnableAudio NOTIFY enableAudioChanged)
	Q_PROPERTY(bool useHwdec READ useHwdec WRITE setUseHwdec NOTIFY useHwdecChanged)

	READONLY_PROP_BOOL("idle-active", idleActive)
	WRITABLE_PROP_BOOL("mute", muted)
	WRITABLE_PROP_BOOL("pause", paused)
	READONLY_PROP_BOOL("paused-for-cache", pausedForCache)
	READONLY_PROP_BOOL("seekable", seekable)
	READONLY_PROP_INT("chapter", chapter)
	READONLY_PROP_INT("chapter-list/count", chapterListCount) // OR "chapters"
	READONLY_PROP_INT("decoder-frame-drop-count", decoderFrameDropCount)
	READONLY_PROP_INT("dheight", dheight)
	READONLY_PROP_INT("dwidth", dwidth)
	READONLY_PROP_INT("estimated-frame-count", estimatedFrameCount)
	READONLY_PROP_INT("estimated-frame-number", estimatedFrameNumber)
	READONLY_PROP_INT("frame-drop-count", frameDropCount)
	WRITABLE_PROP_INT("playlist-pos", playlistPos)
	READONLY_PROP_INT("playlist/count", playlistCount)
	WRITABLE_PROP_INT("vo-delayed-frame-count", voDelayedFrameCount)
	WRITABLE_PROP_INT("volume", volume)
	WRITABLE_PROP_INT("contrast", contrast)
	WRITABLE_PROP_INT("brightness", brightness)
	WRITABLE_PROP_INT("gamma", gamma)
	WRITABLE_PROP_INT("saturation", saturation)
	WRITABLE_PROP_INT("sub-margin-y", subMarginY)
	READONLY_PROP_INT("vid", vid)
	READONLY_PROP_INT("aid", aid)
	READONLY_PROP_INT("sid", sid)
	READONLY_PROP_INT("audio-params/channel-count", audioParamsChannelCount)
	READONLY_PROP_INT("audio-params/samplerate", audioParamsSampleRate)
	READONLY_PROP_INT("track-list/count", trackListCount)
	READONLY_PROP_DOUBLE("audio-bitrate", audioBitrate)
	READONLY_PROP_DOUBLE("avsync", avsync)
	READONLY_PROP_DOUBLE("container-fps", containerFps)
	READONLY_PROP_DOUBLE("demuxer-cache-duration", demuxerCacheDuration)
	READONLY_PROP_DOUBLE("display-fps", displayFps)
	READONLY_PROP_DOUBLE("estimated-display-fps", estimatedDisplayFps)
	READONLY_PROP_DOUBLE("estimated-vf-fps", estimatedVfFps)
	READONLY_PROP_DOUBLE("fps", fps) // Deprecated, use "container-fps"
	WRITABLE_PROP_DOUBLE("speed", speed)
	READONLY_PROP_DOUBLE("video-bitrate", videoBitrate)
	READONLY_PROP_DOUBLE("video-params/aspect", videoParamsAspect)
	READONLY_PROP_DOUBLE("video-out-params/aspect", videoOutParamsAspect)
	WRITABLE_PROP_DOUBLE("window-scale", windowScale)
	READONLY_PROP_DOUBLE("current-window-scale", currentWindowScale)
	READONLY_PROP_STRING("audio-params/format", audioParamsFormat)
	READONLY_PROP_STRING("audio-codec", audioCodec)
	READONLY_PROP_STRING("audio-codec-name", audioCodecName)
	READONLY_PROP_STRING("filename", filename)
	READONLY_PROP_STRING("file-format", fileFormat)
	READONLY_PROP_STRING("file-size", fileSize)
	READONLY_PROP_STRING("audio-format", audioFormat)
	WRITABLE_PROP_STRING("hwdec", hwdec)
	READONLY_PROP_STRING("hwdec-current", hwdecCurrent)
	READONLY_PROP_STRING("hwdec-interop", hwdecInterop)
	READONLY_PROP_STRING("media-title", mediaTitle)
	READONLY_PROP_STRING("path", path)
	READONLY_PROP_STRING("video-codec", videoCodec)
	READONLY_PROP_STRING("video-format", videoFormat)
	READONLY_PROP_STRING("video-params/pixelformat", videoParamsPixelformat)
	READONLY_PROP_STRING("video-out-params/pixelformat", videoOutParamsPixelformat)
	READONLY_PROP_STRING("ytdl-format", ytdlFormat)
	READONLY_PROP_MAP("demuxer-cache-state", demuxerCacheState)

public:
	Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
	Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
	Q_PROPERTY(double position READ position NOTIFY positionChanged)

public:
	MpvObject(QQuickItem *parent = nullptr);
	virtual ~MpvObject();

	virtual Renderer *createRenderer() const;

	Q_INVOKABLE void setProperty(const QString& name, const QVariant& value);
	Q_INVOKABLE QVariant getProperty(const QString& name) const;
	Q_INVOKABLE void setOption(const QString& name, const QVariant& value);

	Q_INVOKABLE QString getPlaylistFilename(int playlistIndex) const { return getProperty(QString("playlist/%1/filename").arg(playlistIndex)).toString(); }
	Q_INVOKABLE QString getPlaylistTitle(int playlistIndex) const { return getProperty(QString("playlist/%1/title").arg(playlistIndex)).toString(); }
	Q_INVOKABLE QString getChapterTitle(int chapterIndex) const { return getProperty(QString("chapter-list/%1/title").arg(chapterIndex)).toString(); }
	Q_INVOKABLE double getChapterTime(int chapterIndex) const { return getProperty(QString("chapter-list/%1/time").arg(chapterIndex)).toDouble(); }

public slots:
	void command(const QVariant& params);
	void commandAsync(const QVariant& params);

	void playPause();
	void play();
	void pause();
	void stop();
	void stepBackward();
	void stepForward();
	void seek(double pos);
	void loadFile(QVariant urls);
	void subAdd(QVariant urls);

	bool enableAudio() const { return m_enableAudio; }
	void setEnableAudio(bool value) {
		if (m_enableAudio != value) {
			m_enableAudio = value;
			Q_EMIT enableAudioChanged(value);
		}
		if (!m_enableAudio) {
			mpv::qt::set_option_variant(mpv, "ao", "null");
		}
	}

	bool useHwdec() const { return m_useHwdec; }
	void setUseHwdec(bool value) {
		if (m_useHwdec != value) {
			m_useHwdec = value;
			if (m_useHwdec) {
				mpv::qt::set_option_variant(mpv, "hwdec", "auto-copy");
			} else {
				mpv::qt::set_option_variant(mpv, "hwdec", "no");
			}
			Q_EMIT useHwdecChanged(value);
		}
	}

	bool isPlaying() const { return m_isPlaying; }
	void updateState();

	double duration() const { return m_duration; }
	double position() const { return m_position; }

signals:
	void enableAudioChanged(bool value);
	void useHwdecChanged(bool value);
	void isPlayingChanged(bool value);

	void durationChanged(double value); // Unit: seconds
	void positionChanged(double value); // Unit: seconds

	void mpvUpdated();

	void logMessage(QString prefix, QString level, QString text);
	void fileStarted();
	void fileEnded(QString reason);
	void fileLoaded();

private slots:
	void onMpvEvents();
	void doUpdate();

protected:
	mpv_handle *mpv;

private:
	void logPropChange(mpv_event_property *prop);
	void handle_mpv_event(mpv_event *event);
	static void on_update(void *ctx);

	bool m_enableAudio;
	bool m_useHwdec;
	double m_duration;
	double m_position;
	bool m_isPlaying;
};

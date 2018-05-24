import QtQuick 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
	id: playbackInfo
	spacing: 0

	PlaybackInfoText { text: mpvObject.filename }
	PlaybackInfoText { text: "State: " + mpvObject.positionStr + "/" + mpvObject.durationStr + "(" + Math.round(mpvObject.positionRatio * 100).toFixed(1) + "%), " + mpvObject.speed.toFixed(2) + "x" }
	PlaybackInfoText { text: "Audio/Video Sync: ±" + Math.round(mpvObject.avsync * 1000) + "ms" }
	PlaybackInfoText { text: "" }
	PlaybackInfoText { text: "Video Track #1: " + mpvObject.videoCodec }
	PlaybackInfoText { text: "Decoder: " + mpvObject.dwidth + "x" + mpvObject.dheight + " " + (mpvObject.containerFps || mpvObject.fps).toFixed(3) + "fps " + mpvObject.videoBitrate + "bps" }
	PlaybackInfoText { text: "Output: " + mpvObject.dwidth + "x" + mpvObject.dheight + " " + mpvObject.estimatedVfFps.toFixed(3) + "fps --bps" }
	PlaybackInfoText { text: "Est. Frame Number: " + mpvObject.estimatedFrameNumber + "/" + mpvObject.estimatedFrameCount }
	PlaybackInfoText { text: "Dropped Frames: " + (mpvObject.frameDropCount || mpvObject.decoderFrameDropCount) }
	PlaybackInfoText { text: "Delayed Frames: " + mpvObject.voDelayedFrameCount }
	PlaybackInfoText { text: "Hardware Acceleration: " + mpvObject.hwdec + '[' + (mpvObject.hwdecCurrent || '--') + ']' }
	PlaybackInfoText { text: "" }
	PlaybackInfoText { text: "Audio Track #1: " + mpvObject.audioCodec }
	PlaybackInfoText { text: "Decoder: " + mpvObject.audioBitrate + "bps" }
	PlaybackInfoText { text: "" }
}

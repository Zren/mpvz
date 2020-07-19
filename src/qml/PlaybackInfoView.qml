import QtQuick 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
	id: playbackInfo
	spacing: 16

	PlaybackInfoSection {
		heading.key: "File"
		heading.value: mpvObject.filename

		PlaybackInfoText { key: "Title"; value: mpvObject.mediaTitle; visible: mpvObject.filename != mpvObject.mediaTitle }
	}

	PlaybackInfoSection {
		heading.key: "State"
		heading.value: mpvObject.positionStr + "/" + mpvObject.durationStr + "(" + Math.round(mpvObject.positionRatio * 100).toFixed(1) + "%), " + mpvObject.speed.toFixed(2) + "x [" + mpvObject.stateStr + "]"

		PlaybackInfoText { key: "Audio/Video Sync"; value: "±" + Math.round(mpvObject.avsync * 1000) + "ms" }
	}

	PlaybackInfoSection {
		heading.key: "Video Track #" + mpvObject.vid
		heading.value: mpvObject.videoCodec

		// PlaybackInfoText { key: "Display FPS"; value: "" + mpvObject.displayFps.toFixed(3) + "fps (specified) " + mpvObject.estimatedDisplayFps.toFixed(3) + "fps (estimated)" }
		// PlaybackInfoText { key: "FPS"; value: "" + mpvObject.containerFps.toFixed(3) + "fps (specified) " + mpvObject.estimatedVfFps.toFixed(3) + "fps (estimated)" }

		PlaybackInfoText { key: "Decoder"; value: mpvObject.dwidth + "x" + mpvObject.dheight + " " + (mpvObject.containerFps || mpvObject.fps).toFixed(3) + "fps " + mpvObject.videoBitrate + "bps" }
		PlaybackInfoText { key: "Output"; value: mpvObject.dwidth + "x" + mpvObject.dheight + " " + mpvObject.estimatedVfFps.toFixed(3) + "fps --bps" }
		PlaybackInfoText { key: "Est. Frame Number"; value: mpvObject.estimatedFrameNumber + "/" + mpvObject.estimatedFrameCount }
		PlaybackInfoText { key: "Dropped Frames"; value: '' + mpvObject.decoderFrameDropCount + ' (decoder) ' + mpvObject.frameDropCount + ' (output)' }
		PlaybackInfoText { key: "Delayed Frames"; value: mpvObject.voDelayedFrameCount }
		PlaybackInfoText { key: "Hardware Acceleration"; value: mpvObject.hwdec + '[' + (mpvObject.hwdecCurrent || '--') + ']' }
		PlaybackInfoText { key: "Window Scale"; value: mpvObject.currentWindowScale }
		PlaybackInfoText { key: "Aspect Ratio"; value: mpvObject.videoParamsAspect.toFixed(2) }
		PlaybackInfoText { key: "Pixel Format"; value: mpvObject.videoParamsPixelformat || mpvObject.videoOutParamsPixelformat }
	}

	PlaybackInfoSection {
		heading.key: "Audio Track #" + mpvObject.aid
		heading.value: mpvObject.audioCodec

		PlaybackInfoText { key: "Decoder"; value: mpvObject.audioBitrate + "bps" }
	}
}

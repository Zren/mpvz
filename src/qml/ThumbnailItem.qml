import mpvz 1.0
import QtQuick 2.0

MpvObject {
	id: mpvThumb
	anchors.fill: parent

	enableAudio: false

	Component.onCompleted: {
		mpvThumb.setOption("sid", "no") // Hide subs
		mpvThumb.setOption("hr-seek", "no") // Don't use precise seek
		mpvThumb.setOption("sstep", "10") // Step every 10 seconds
		// mpvThumb.setOption("frames", "1")
		// mpvThumb.setOption("of", "image2")
		// mpvThumb.setOption("ovc", "rawvideo")
		mpvThumb.setOption("pause", "")
		var thumbPosition = Math.floor(thumbnail.videoPosition) // 1 second interval
		mpvThumb.setOption("start", '+'+thumbPosition)
		if (mpvThumb.path != mpvObject.path) {
			mpvThumb.loadFile(mpvObject.path)
		}
	}

	readonly property double steppedPos: Math.floor(thumbnail.videoPosition)
	onSteppedPosChanged: {
		if (mpvThumb.path != mpvObject.path) {
			mpvThumb.loadFile(mpvObject.path)
		}
		visible = false
		thumbSeekDebounce.restart()
	}
	Timer {
		id: thumbSeekDebounce
		interval: 50
		onTriggered: {
			mpvThumb.seek(steppedPos)
			visible = true
		}
	}
}

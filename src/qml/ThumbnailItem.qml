import mpvz 1.0
import QtQuick 2.0

MpvThumbnail {
	id: mpvThumb
	objectName: "mpvThumb"
	anchors.fill: parent

	Component.onCompleted: {
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

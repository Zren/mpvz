import mpvz 1.0
import QtQuick 2.0

MpvObject {
	id: mpvThumb
	anchors.fill: parent

	enableAudio: false

	Component.onCompleted: {
		mpvThumb.setOption("sid", "no")
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

	Connections {
		target: thumbnail
		onVideoPositionChanged: {
			if (mpvThumb.path != mpvObject.path) {
				mpvThumb.loadFile(mpvObject.path)
			}
			var thumbPosition = Math.floor(thumbnail.videoPosition) // 1 second interval
			mpvThumb.seek(thumbPosition)
		}
	}
}

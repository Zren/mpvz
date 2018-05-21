import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import mpvz 1.0

Item {
	id: mpvPlayer
	objectName: "mpvPlayer"
	property alias mpvObject: mpvObject

	MpvObject {
		id: mpvObject
		objectName: "mpvObject"
		anchors.fill: parent

		MouseArea {
			id: videoMouseArea
			anchors.fill: parent
			acceptedButtons: Qt.AllButtons
			hoverEnabled: true
			property double lastClickToPause: 0
			onClicked: {
				if (mouse.button == Qt.LeftButton) {
					lastClickToPause = Date.now()
					mpvObject.playPause()
				} else if (mouse.button == Qt.RightButton) {
					contextMenu.popup()
				}
			}
			onDoubleClicked: {
				mpvObject.playPause()
				window.toggleFullscreen()
			}
			
			cursorShape: Qt.ArrowCursor
			onPositionChanged: {
				videoMouseArea.cursorShape = Qt.ArrowCursor
				hideCursorTimeout.restart()
			}
			Timer {
				id: hideCursorTimeout
				interval: 700
				onTriggered: videoMouseArea.cursorShape = Qt.BlankCursor
			}
		}

		function loadfile(filepath) {
			mpvObject.command(["loadfile", filepath])
		}

		// onMpvUpdated: console.log('onMpvUpdated', Date.now())
		// onPositionChanged: console.log('onPositionChanged', value)
		onDurationChanged: console.log('onDurationChanged', value)
	}



	Item {
		id: overlayControls
		anchors.fill: parent
		property bool showOverlay: controlBar.containsMouse || hideCursorTimeout.running
        

		opacity: overlayControls.showOverlay ? 1 : 0
		Behavior on opacity {
			NumberAnimation { duration: overlayControls.showOverlay ? 400 : 0 }
		}

		Rectangle {
			anchors.fill: parent
			
			gradient: Gradient {
				GradientStop { position: 0.0; color: "#FF000000" }
				GradientStop { position: 0.2; color: "#00000000" }
				GradientStop { position: 0.8; color: "#00000000" }
				GradientStop { position: 1.0; color: "#FF000000" }
			}
		}

		ControlBar {
			id: controlBar
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			
			acceptedButtons: overlayControls.showOverlay ? Qt.AllButtons : Qt.NoButton
        	propagateComposedEvents: overlayControls.showOverlay ? false : true
		}
	}
	


	function zeroPad(n) {
		var s = n.toString()
		if (s.length == 0) s = "0"
		if (s.length == 1) s = "0" + s
		return s
	}
	function formatTime(t) {
		var totalSeconds = Math.floor(t)
		var seconds = totalSeconds % 60
		var hours = Math.floor(totalSeconds / 3600)
		var minutes = Math.floor((totalSeconds - hours * 3600) / 60)
		return zeroPad(hours) + ":" + zeroPad(minutes) + ":" + zeroPad(seconds)
	}
	function formatShortTime(t) {
		var totalSeconds = Math.floor(t)
		var seconds = totalSeconds % 60
		var hours = Math.floor(totalSeconds / 3600)
		var minutes = Math.floor((totalSeconds - hours * 3600) / 60)
		var s = ""
		if (hours > 0) {
			return hours + ":" + zeroPad(minutes) + ":" + zeroPad(seconds)
		} else {
			return minutes + ":" + zeroPad(seconds)
		}
	}
}

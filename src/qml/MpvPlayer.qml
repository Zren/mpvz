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
				interval: 1000
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


	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom

		Slider {
			id: seekSlider
			Layout.fillWidth: true

			Connections {
				target: mpvObject
				onPositionChanged: {
					// console.log('onPositionChanged', mpvObject.position, seekSlider.value)
					if (mpvObject.duration > 0 && !seekSlider.pressed && !seekDebounce.running) {
						seekSlider.value = mpvObject.position
					}
				}
				onDurationChanged: {
					seekSlider.maximumValue = mpvObject.duration
				}
			}

			minimumValue: 0

			Timer {
				id: seekDebounce
				interval: 100
				onTriggered: mpvObject.seek(seekSlider.value)
			}

			onValueChanged: {
				// console.log('slider.value', value)
				if (pressed) {
					seekDebounce.restart()
				}
			}
			onMaximumValueChanged: console.log('slider.maxValue', maximumValue)
		}

		RowLayout {
			Layout.fillWidth: true
			
			ToolButton {
				iconSource: mpvObject.paused ? "qrc:icons/media-playback-start.png" : "qrc:icons/media-playback-pause.png"
				// iconSource: mpvObject.paused ? "media-playback-start" : "media-playback-pause"
				onClicked: mpvObject.playPause()
			}

			Label {
				text: "" + formatShortTime(mpvObject.position) + " / " + formatShortTime(mpvObject.duration)
			}

			Item {
				Layout.fillWidth: true
			}
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

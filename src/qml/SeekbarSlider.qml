import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import mpvz 1.0

// Fork Slider so that mouseArea is exposed because using a child MouseArea conflicts.
// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Slider.qml
AppSlider {
	id: slider

	property bool ignoreValueChange: false
	property bool playingOnPressed: false

	Connections {
		target: mpvObject
		onFileLoaded: {
			slider.ignoreValueChange = true
			slider.value = 0
			slider.ignoreValueChange = false
		}
		onPositionChanged: {
			// console.log('onPositionChanged', mpvObject.position, slider.value)
			if (mpvObject.duration > 0 && !slider.pressed && !seekDebounce.running) {
				slider.ignoreValueChange = true
				slider.value = mpvObject.position
				slider.ignoreValueChange = false
			}
		}
		onDurationChanged: {
			slider.maximumValue = mpvObject.duration
		}
	}
	
	minimumValue: 0

	// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Private/qquickwheelarea_p.h
	WheelArea {
		id: wheelarea
		anchors.fill: parent
		horizontalMinimumValue: slider.minimumValue
		horizontalMaximumValue: slider.maximumValue
		verticalMinimumValue: slider.minimumValue
		verticalMaximumValue: slider.maximumValue

		onVerticalWheelMoved: {
			// console.log('onVerticalWheelMoved', verticalDelta)
			if (verticalDelta > 0) { // Scroll up
				slider.decrement()
			} else if (verticalDelta < 0) { // Scroll down
				slider.increment()
			}
		}

		onHorizontalWheelMoved: {
			// console.log('onHorizontalWheelMoved', horizontalDelta)
			if (horizontalDelta > 0) { // Scroll ?
				slider.decrement()
			} else if (horizontalDelta < 0) { // Scroll ?
				slider.increment()
			}
		}
	}

	mouseArea.hoverEnabled: true
	mouseArea.onPositionChanged: {
		// console.log('onPositionChanged', mouse.x, mouseArea.width)
		thumbnail.show(mouse.x)
	}
	mouseArea.onContainsMouseChanged: {
		if (!mouseArea.containsMouse) {
			thumbnail.hide()
		}
	}

	property int visibleSliderHeight: 4
	property int topPadding: 8
	property int bottomPadding: 8
	property int handleSize: 16
	implicitHeight: topPadding + visibleSliderHeight + bottomPadding // 20

	style: AppSliderStyle {
		groove: Item {
			implicitWidth: 200
			implicitHeight: control.height

			// [invisibleSliderHeight area that can be pressed]
			
			Rectangle {
				id: grooveRect
				anchors.bottom: parent.bottom
				anchors.bottomMargin: control.bottomPadding
				width: parent.width
				height: control.visibleSliderHeight

				radius: height

				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						x: grooveRect.x
						y: grooveRect.y
						width: grooveRect.width
						height: grooveRect.height
						radius: grooveRect.radius
					}
				}
				
				color: "#33FFFFFF"

				Rectangle {
					width: styleData.handlePosition
					height: parent.height

					color: "#3DAEE6"
				}
			}

			Item {
				id: chapterMarkers
				anchors.fill: grooveRect

				Repeater {
					model: mpvObject.chapterListCount

					Image {
						readonly property double chapterPosition: mpvObject.getChapterTime(index)
						readonly property double positionRatio: slider.maximumValue ? chapterPosition / slider.maximumValue : 0
						x: control.width * positionRatio - width/2
						y: chapterMarkers.height/2
						width: 8
						height: 8
						source: "qrc:icons/Tethys/marker.png"
					}
				}
			}
		}

		handle: Item {
			height: parent.height

			Rectangle {
				anchors.centerIn: parent
				property int size: slider.mouseArea.containsMouse ? control.handleSize : 0
				width: size
				height: size
				radius: control.handleSize
				Behavior on size {
					NumberAnimation { duration: 400 }
				}
			}
		}
	}

	Rectangle {
		id: thumbnail
		property int borderWidth: 2
		border.width: borderWidth
		border.color: "#0e1115"

		gradient: Gradient {
			GradientStop { position: 0.0; color: "#19181a" }
			GradientStop { position: 1.0; color: "#0e1115" }
		}

		property int contentWidth: 200
		property int contentHeight: Math.ceil(contentWidth * (mpvObject.dheight / mpvObject.dwidth))
		width: contentWidth + border.width*2
		height: contentHeight + border.width*2
		anchors.bottom: parent.top
		visible: false
		property real positionRatio: 0
		readonly property double videoPosition: mpvObject.duration * positionRatio
		// onPositionChanged: thumbnailVideo.seekToPosition()
		property int mouseX: 0
		x: Math.max(0, Math.min(mouseX - (width / 2), parent.width - width))

		function show(mouseX) {
			thumbnail.mouseX = mouseX
			thumbnail.positionRatio = Math.max(0, Math.min(thumbnail.mouseX / mouseArea.width, 1))
			thumbLoader.active = true
			// if (mpvThumb.path != mpvObject.path) {
			// 	mpvThumb.loadFile(mpvObject.path)
			// }
			// mpvThumb.pause()
			// var thumbPosition = Math.floor(thumbnail.videoPosition) // 1 second interval
			// var thumbPosition = thumbnail.videoPosition
			// mpvThumb.seek(thumbPosition)
			// mpvThumb.play()
			thumbnail.visible = true
		}

		function hide() {
			thumbnail.visible = false
			// mpvThumb.command("stop")
			// mpvThumb.loadFile("")
			// thumbLoader.active = false
		}

		property alias mpvThumb: thumbLoader.item

		Rectangle {
			anchors.fill: parent
			border.width: thumbnail.border.width
			border.color: thumbnail.border.color
			color: "#000"

			// MpvThumb {
			// 	id: mpvThumb
			// 	anchors.fill: parent
			// 	anchors.margins: parent.border.width
			// }

			Loader {
				id: thumbLoader
				anchors.fill: parent
				anchors.margins: thumbnail.border.width
				active: false
				source: "ThumbnailItem.qml"
			}

			Rectangle {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 4

				color: "#88000000"
				radius: 4

				property int padding: 4
				width: padding + thumbPosText.implicitWidth + padding
				height: padding + thumbPosText.implicitHeight + padding

				Text {
					id: thumbPosText
					x: parent.padding
					y: parent.padding
					text: mpvPlayer.formatShortTime(thumbnail.videoPosition)
					color: "#FFFFFF"
				}
			}
		}
	}

	onPressedChanged: {
		if (pressed) {
			playingOnPressed = !mpvObject.paused
			// mpvObject.pause()
		}
		seekToValue()
		if (!pressed && playingOnPressed) {
			mpvObject.play()
		}
	}

	onValueChanged: {
		if (!ignoreValueChange) {
			seekDebounce.restart()
		}
	}

	Timer {
		id: seekDebounce
		interval: 100
		running: slider.pressed
		onTriggered: {
			seekToValue()
			if (slider.pressed) {
				restart()
			}
		}
	}

	function seekToValue() {
		mpvObject.seek(slider.value)
	}

	property real incrementSize: 5 // 5 seconds
	function decrement() {
		var nextValue = slider.value - incrementSize
		nextValue = Math.max(0, Math.min(nextValue, maximumValue))
		mpvObject.seek(nextValue)
	}
	function increment() {
		var nextValue = slider.value + incrementSize
		nextValue = Math.max(0, Math.min(nextValue, maximumValue))
		mpvObject.seek(nextValue)
	}
}

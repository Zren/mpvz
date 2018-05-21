import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

// Fork Slider so that mouseArea is exposed because using a child MouseArea conflicts.
// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Slider.qml
AppSlider {
	id: seekbar

	property bool ignoreValueChange: false
	property bool playingOnPressed: false

	Connections {
		target: mpvObject
		onPositionChanged: {
			// console.log('onPositionChanged', mpvObject.position, seekSlider.value)
			if (mpvObject.duration > 0 && !seekSlider.pressed && !seekDebounce.running) {
				seekbar.ignoreValueChange = true
				seekSlider.value = mpvObject.position
				seekbar.ignoreValueChange = false
			}
		}
		onDurationChanged: {
			seekSlider.maximumValue = mpvObject.duration
		}
	}
	
	minimumValue: 0

	// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Private/qquickwheelarea_p.h
	WheelArea {
		id: wheelarea
		anchors.fill: parent
		horizontalMinimumValue: seekbar.minimumValue
		horizontalMaximumValue: seekbar.maximumValue
		verticalMinimumValue: seekbar.minimumValue
		verticalMaximumValue: seekbar.maximumValue

		onVerticalWheelMoved: {
			console.log('onVerticalWheelMoved', verticalDelta)
			if (verticalDelta > 0) { // Scroll up
				seekbar.decrement()
			} else if (verticalDelta < 0) { // Scroll down
				seekbar.increment()
			}
		}

		onHorizontalWheelMoved: {
			console.log('onHorizontalWheelMoved', horizontalDelta)
			if (horizontalDelta > 0) { // Scroll ?
				seekbar.decrement()
			} else if (horizontalDelta < 0) { // Scroll ?
				seekbar.increment()
			}
		}
	}

	mouseArea.hoverEnabled: true
	mouseArea.onPositionChanged: {
		// console.log('onPositionChanged', mouse.x, mouseArea.width)
		// thumbnail.show(mouse.x)
	}
	mouseArea.onContainsMouseChanged: {
		if (!mouseArea.containsMouse) {
			// thumbnail.hide()
		}
	}

	property int visibleSliderHeight: 4
	property int topPadding: 8
	property int bottomPadding: 8
	implicitHeight: topPadding + visibleSliderHeight + bottomPadding // 20

	style: AppSliderStyle {
		groove: Item {
			implicitWidth: 200
			implicitHeight: control.height

			// [invisibleSliderHeight area that can be pressed]
			
			Rectangle {
				id: grooveRect
				anchors.bottom: parent.bottom
				anchors.bottomMargin: control.bottomMargin
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
		}

		handle: Item {}
	}

	onPressedChanged: {
		seekToValue()
		
		if (pressed) {
			playingOnPressed = !mpvObject.paused
			mpvObject.pause()
		} else if (!pressed && playingOnPressed) {
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
		running: seekbar.pressed
		onTriggered: {
			seekToValue()
			if (seekbar.pressed) {
				restart()
			}
		}
	}

	function seekToValue() {
		mpvObject.seek(seekSlider.value)
	}

	property real incrementSize: 5 // 5 seconds
	function decrement() {
		mpvObject.seek(seekSlider.value - incrementSize)
	}
	function increment() {
		mpvObject.seek(seekSlider.value + incrementSize)
	}
}

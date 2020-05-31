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

	minimumValue: 0
	maximumValue: 100

	Connections {
		target: mpvObject
		onMutedChanged: {
			slider.ignoreValueChange = true
			if (mpvObject.muted) {
				slider.value = 0
			} else {
				slider.value = mpvObject.volume
			}
			slider.ignoreValueChange = false
		}
		onVolumeChanged: {
			// console.log('onVolumeChanged', mpvObject.volume, slider.value)
			if (!slider.pressed && !volumeDebounce.running) {
				slider.ignoreValueChange = true
				slider.value = mpvObject.volume
				slider.ignoreValueChange = false
			}
		}
	}

	property int visibleSliderHeight: 4
	property int topPadding: 16
	property int bottomPadding: 16
	property int handleSize: 12
	implicitHeight: topPadding + visibleSliderHeight + bottomPadding // 36

	style: AppSliderStyle {
		groove: Item {
			implicitWidth: 80
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

					color: "#FFFFFF"
				}
			}
		}

		handle: Item {
			height: parent.height

			Rectangle {
				anchors.centerIn: parent
				property int size: control.handleSize
				width: size
				height: size
				radius: control.handleSize
			}
		}
	}

	onPressedChanged: {
		setVolumeToValue()
	}

	onValueChanged: {
		if (!ignoreValueChange) {
			volumeDebounce.restart()
		}
	}

	Timer {
		id: volumeDebounce
		interval: 100
		running: slider.pressed
		onTriggered: {
			setVolumeToValue()
			if (slider.pressed) {
				restart()
			}
		}
	}

	function setVolumeToValue() {
		mpvObject.setVolume(slider.value)
	}
}

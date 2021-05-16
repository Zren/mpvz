import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Layouts 1.0

ToolButton {
	id: control
	property string iconName: ""
	iconSource: {
		if (iconName) {
			if (pressed) {
				return "qrc:icons/Tethys/" + iconName + "-pressed.png"
			} else if (hovered) {
				return "qrc:icons/Tethys/" + iconName + "-hovered.png"
			} else {
				return "qrc:icons/Tethys/" + iconName + ".png"
			}
		} else {
			return ""
		}
	}
	implicitHeight: 36
	Layout.minimumWidth: 36

	text: ""

	opacity: hovered ? 1 : 0.75
	style: ButtonStyle {
		background: Item {}

		// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Styles/Base/ButtonStyle.qml#L129
		label: Item {
			implicitWidth: row.implicitWidth
			implicitHeight: row.implicitHeight
			baselineOffset: row.y + text.y + text.baselineOffset
			Row {
				id: row
				anchors.centerIn: parent
				spacing: 2
				Image {
					source: control.iconSource
					anchors.verticalCenter: parent.verticalCenter
					visible: status == Image.Ready
				}
				Text {
					id: text
					renderType: Settings.isMobile ? Text.QtRendering : Text.NativeRendering
					anchors.verticalCenter: parent.verticalCenter
					text: StyleHelpers.stylizeMnemonics(control.text)
					color: "#FFFFFF"
					style: Text.Raised
					styleColor: "#111111"
				}
			}
		}
	}

	property bool tooltipAbove: true
	property alias tooltipText: tooltipLabel.text
	Rectangle {
		id: tooltip

		property int seekbarSpacing: 4
		function calcX() {
			var container = tooltipAbove ? controlBar : headerBar
			var parentPos = control.mapToItem(container, 0, 0)
			var xOffset = Math.floor((control.width - tooltip.implicitWidth)/2)
			var offsetPosX = parentPos.x + xOffset
			if (tooltip.implicitWidth <= control.width) {
				// Tooltip isn't wider than parent, so there's room.
				return xOffset
			} else if (offsetPosX < 0) {
				// Left align tooltip
				return 0
			} else if (offsetPosX + tooltip.implicitWidth > container.width) {
				// Right align tooltip
				return control.width - tooltip.implicitWidth
			} else { // Tooltip fits within window 
				return xOffset
			}
		}
		function calcY() {
			if (tooltipAbove) {
				return -seekSlider.implicitHeight - seekbarSpacing - tooltip.implicitHeight
			} else {
				return tooltip.implicitHeight + seekbarSpacing
			}
		}
		function updatePos() {
			x = calcX()
			y = calcY()
		}
		onVisibleChanged: {
			if (visible) {
				updatePos()
			}
		}

		visible: tooltipLabel.text && control.hovered
		color: "#333333"
		radius: 4

		property int padding: 6
		implicitWidth: tooltipLabel.implicitWidth + padding * 2
		implicitHeight: tooltipLabel.implicitHeight + padding * 2

		Text {
			id: tooltipLabel
			anchors.centerIn: parent
			text: {
				if (control.action) {
					if (control.action.shortcut) {
						return control.action.text + " (" + control.action.shortcut + ")"
					} else {
						return control.action.text
					}
				} else {
					return ""
				}
			}
			color: "#FFFFFF"
			style: Text.Raised
			styleColor: "#111111"
		}
	}

}

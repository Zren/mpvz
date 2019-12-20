import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Layouts 1.0

ToolButton {
	id: control
	property string iconName: ""
	iconSource: {
		if (pressed) {
			return "qrc:icons/Tethys/" + iconName + "-pressed.png"
		} else if (hovered) {
			return "qrc:icons/Tethys/" + iconName + "-hovered.png"
		} else {
			return "qrc:icons/Tethys/" + iconName + ".png"
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

	property alias tooltipText: tooltipLabel.text
	Rectangle {
		id: tooltip

		property int seekbarSpacing: 4
		y: -seekSlider.implicitHeight - seekbarSpacing - tooltip.implicitHeight
		
		visible: tooltipLabel.text && control.hovered
		color: "#333333"
		radius: 4

		property int padding: 6
		implicitWidth: tooltipLabel.implicitWidth + padding * 2
		implicitHeight: tooltipLabel.implicitHeight + padding * 2

		Text {
			id: tooltipLabel
			anchors.centerIn: parent
			text: control.action ? control.action.text + " (" + control.action.shortcut + ")" : ""
			color: "#FFFFFF"
			style: Text.Raised
			styleColor: "#111111"
		}
	}
}

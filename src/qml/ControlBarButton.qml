import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

ToolButton {
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
	implicitWidth: 36

	opacity: hovered ? 1 : 0.75
	style: ButtonStyle {
		background: Item {}
	}
}

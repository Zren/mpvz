import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

ToolButton {
	property string iconName: ""
	iconSource: "qrc:icons/" + iconName + ".svg"

	opacity: hovered ? 1 : 0.75
	style: ButtonStyle {
		background: Item {}
	}
}

import QtQuick 2.0
import QtQuick.Layouts 1.0

Rectangle {
	id: shortcutLabel
	Layout.alignment: Qt.AlignHCenter

	implicitWidth: Math.max(implicitHeight, padding + label.implicitWidth + padding)
	implicitHeight: padding + label.implicitHeight + padding

	property int padding: 2
	property alias text: label.text
	color: "#CCC"
	radius: 4

	Text {
		id: label
		anchors.centerIn: parent
		color: "#111"
		font.pixelSize: 14
		font.family: "Monospace"
		font.weight: Font.Bold
	}
}

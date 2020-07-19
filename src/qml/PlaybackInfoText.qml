import QtQuick 2.0
import QtQuick.Layouts 1.0

Text {
	property string key: ""
	property string value: ""
	text: "<b>" + key + ":</b> " + value
	color: "#FFF"
	style: Text.Outline
	styleColor: "#000"
	font.pixelSize: 14
	font.family: "Monospace"
	wrapMode: Text.Wrap
	Layout.fillWidth: true
}

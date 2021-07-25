import QtQuick 2.0
import QtQuick.Layouts 1.0

Text {
	property string key: ""
	property string value: ""
	text: "<b>" + key + ":</b> " + value.replace('<', '&lt;').replace('>', '&gt;')
	color: "#FFF"
	style: Text.Outline
	styleColor: "#444"
	font.pixelSize: 16
	font.family: "Monospace"
	wrapMode: Text.Wrap
	Layout.fillWidth: true
	textFormat: Text.StyledText
}

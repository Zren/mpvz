import QtQuick 2.0

Text {
	property string key: ""
	text: "" + key + ": " + mpvObject[key]
	color: "#FF0"
	style: Text.Outline
	styleColor: "#000"
	font.pixelSize: 20
	font.family: "Noto Mono"
}

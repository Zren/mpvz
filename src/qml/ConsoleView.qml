import QtQuick 2.0
import QtQuick.Controls 1.0

ScrollView {
	id: consoleView

	Text {
		id: logLabel
		color: "#FFF"
		style: Text.Outline
		styleColor: "#000"

		Connections {
			target: mpvObject
			onLogMessage: {
				logLabel.text += '[' + prefix + '] ' + text
				consoleView.flickableItem.contentY = consoleView.contentItem.height
			}
		}
	}
}

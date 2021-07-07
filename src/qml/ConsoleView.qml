import QtQuick 2.0
import QtQuick.Controls 1.0

ScrollView {
	id: consoleView

	ListView {
		id: listView
		model: logModel
		delegate: Text {
			id: logLabel
			color: {
				if (model.level == "error") {
					return "#f2777a"
				} else if (model.level == "warn") {
					return "#fac864"
				} else if (model.level == "v") {
					return "#f2777a"
				} else if (model.level == "debug") {
					return "#6c8b7b"
				} else {
					return "#fff"
				}
			}
			style: Text.Outline
			styleColor: "#444"
			text: '[' + model.prefix + '] ' + model.text
		}

		onCountChanged: {
			positionViewAtEnd()
			scrollTimer.restart()
		}
		property Timer scrollTimer: Timer {
			interval: 400
			onTriggered: listView.positionViewAtEnd()
		}

		Component.onCompleted: {
			positionViewAtEnd()
		}
	}
}

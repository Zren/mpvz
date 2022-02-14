import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0

Window {
	visible: true
	width: 1200
	height: 400
	color: "#000"

	SplitView {
		anchors.fill: parent
		orientation: Qt.Horizontal

		ColumnLayout {
			Layout.fillWidth: true
			Layout.preferredWidth: 700

			ScrollView {
				id: consoleView
				Layout.fillWidth: true
				Layout.fillHeight: true

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
						// style: Text.Outline
						// styleColor: "#444"
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
			TextField {
				id: inputField
				Layout.fillWidth: true
				onAccepted: {
					mpvObject.commandAsync(text.split(" "))
					text = ""
				}
			}
		}
		ColumnLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredWidth: 500
			Layout.minimumWidth: 300
			
			ScrollView {
				id: propertyScrollView
				Layout.fillWidth: true
				Layout.fillHeight: true

				ListView {
					id: propertyListView
					property var propertyListModel: mpvObject.getProperty("property-list").sort()
					property var propertyFilterModel: propertyListModel
					model: propertyFilterModel
					delegate: RowLayout {
						width: ListView.view.width
						Text {
							text: modelData + ":"
							font.weight: Font.Bold
							Layout.alignment: Qt.AlignTop
							color: "#fff"
							// style: Text.Outline
							// styleColor: "#444"
						}
						Text {
							text: mpvObject.getProperty(modelData)
							wrapMode: Text.Wrap
							color: "#ddd"
							Layout.fillWidth: true
							Layout.alignment: Qt.AlignTop
						}
					}
					function applyFilter() {
						var query = propertyFilterField.text.toLowerCase()
						propertyFilterModel = propertyListModel.filter(function(key){
							if (query) {
								return key.toLowerCase().includes(query)
							} else {
								return true
							}
						})
					}
				}
			}
			TextField {
				id: propertyFilterField
				Layout.fillWidth: true
				onTextChanged: propertyListView.applyFilter()
			}
		}
	}

}

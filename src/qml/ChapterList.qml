import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Flickable {

	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 0

		Repeater {
			model: mpvObject.chapterListCount
			
			MouseArea {
				Layout.fillWidth: true
				Layout.preferredHeight: chapterButtonContents.implicitHeight

				onClicked: controlBar.seekSlider.value = mpvObject.getChapterTime(index)

				Rectangle {
					anchors.fill: parent
					anchors.bottomMargin: 1
					color: "#88111111"
				}
				Rectangle {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					height: 1
					color: "#CC111111"
				}

				RowLayout {
					id: chapterButtonContents
					spacing: 0

					Item {
						Layout.preferredWidth: 36
						Layout.preferredHeight: 36

						Image {
							anchors.fill: parent
							visible: mpvObject.chapter == index
							source: "qrc:icons/Tethys/play.png"
						}
						
					}
					ColumnLayout {
						spacing: 0
						Text {
							text: mpvObject.getChapterTitle(index)
							color: "#fff"
							font.pixelSize: 14
							font.weight: Font.Bold
							maximumLineCount: 1
							elide: Text.ElideRight
						}
						Text {
							text: formatShortTime(mpvObject.getChapterTime(index))
							color: "#fff"
							font.pixelSize: 12
							maximumLineCount: 1
							elide: Text.ElideRight
						}
					}
				}
			}
			
		}

		Item {
			Layout.fillHeight: true
		}
	}
}
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
				id: chapterItem
				Layout.fillWidth: true
				Layout.preferredHeight: chapterButtonContents.implicitHeight

				readonly property string chapterTitle: mpvObject.getChapterTitle(index)
				readonly property double chapterTime: mpvObject.getChapterTime(index)

				onClicked: controlBar.seekSlider.value = chapterTime

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
							text: chapterTitle || ("Chapter #" + (index + 1))
							color: "#fff"
							font.pixelSize: 14
							font.weight: Font.Bold
							maximumLineCount: 1
							elide: Text.ElideRight
						}
						Text {
							text: formatShortTime(chapterTime)
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
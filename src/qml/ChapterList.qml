import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

AppScrollView {
	id: scrollView

	Repeater {
		model: mpvObject.chapterListCount
		
		MouseArea {
			id: chapterItem
			Layout.fillWidth: true
			property int padding: 4
			Layout.preferredHeight: padding + chapterButtonContents.implicitHeight + padding

			readonly property string chapterTitle: mpvObject.getChapterTitle(index)
			readonly property double chapterStartTime: mpvObject.getChapterTime(index)
			readonly property double chapterEndTime: {
				if (index == mpvObject.chapterListCount - 1) { // Last Chapter
					return mpvObject.duration
				} else {
					return mpvObject.getChapterTime(index + 1)
				}
			}

			onClicked: controlBar.seekSlider.value = chapterStartTime

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				height: 1
				color: "#22FFFFFF"
			}

			RowLayout {
				id: chapterButtonContents
				x: chapterItem.padding
				y: chapterItem.padding
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
						text: formatShortTime(chapterStartTime) + " ⇒ " + formatShortTime(chapterEndTime)
						color: "#fff"
						font.pixelSize: 11
						font.weight: Font.Bold
						opacity: 0.6
						maximumLineCount: 1
						elide: Text.ElideRight
					}
				}
			}
		}
	}
}

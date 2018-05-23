import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1

AppScrollView {
	id: scrollView

	Repeater {
		model: mpvObject.playlistCount
		
		MouseArea {
			id: playlistItem
			Layout.fillWidth: true
			property int padding: 4
			Layout.preferredHeight: padding + chapterButtonContents.implicitHeight + padding

			function basename(str) {
				return (str.slice(str.lastIndexOf("/")+1))
			}
			readonly property string itemFilename: mpvObject.getPlaylistFilename(index)
			readonly property string itemFileBasename: basename(itemFilename)
			readonly property string itemTitle: mpvObject.getPlaylistTitle(index)
			readonly property bool isCurrentItem: mpvObject.playlistPos == index

			onClicked: mpvObject.playlistPos = index

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				height: 1
				color: "#22FFFFFF"
			}

			RowLayout {
				id: chapterButtonContents
				x: playlistItem.padding
				y: playlistItem.padding
				spacing: 0

				Item {
					Layout.preferredWidth: 36
					Layout.preferredHeight: 36

					Image {
						anchors.fill: parent
						visible: isCurrentItem
						source: "qrc:icons/Tethys/play.png"
					}
					
				}
				ColumnLayout {
					spacing: 0
					Text {
						text: itemFileBasename
						color: "#fff"
						font.pixelSize: 14
						font.weight: Font.Bold
						maximumLineCount: 1
						elide: Text.ElideRight
					}
				}
			}
		}
	}
}

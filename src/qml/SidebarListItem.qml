import QtQuick 2.0
import QtQuick.Layouts 1.0

MouseArea {
	id: sidebarListItem
	Layout.fillWidth: true
	property int padding: 4
	Layout.preferredHeight: padding + buttonContents.implicitHeight + padding

	property alias text: line1.text
	property alias description: line2.text
	property bool isCurrentItem: false

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: 1
		color: "#22FFFFFF"
	}

	RowLayout {
		id: buttonContents
		x: sidebarListItem.padding
		y: sidebarListItem.padding
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
				id: line1
				color: "#fff"
				font.pixelSize: 14
				font.weight: Font.Bold
				maximumLineCount: 1
				elide: Text.ElideRight
			}
			Text {
				id: line2
				visible: text
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

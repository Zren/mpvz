import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

MouseArea {
	implicitHeight: columnLayout.implicitHeight
	hoverEnabled: true

	ColumnLayout {
		id: columnLayout
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: 20
		anchors.rightMargin: 20
		spacing: 0

		SeekbarSlider {
			id: seekSlider
			Layout.fillWidth: true
		}

		RowLayout {
			Layout.fillWidth: true
			
			ControlBarButton {
				iconName: mpvObject.paused ? "media-playback-start" : "media-playback-pause"
				onClicked: mpvObject.playPause()
			}

			Label {
				text: "" + mpvPlayer.formatShortTime(mpvObject.position) + " / " + mpvPlayer.formatShortTime(mpvObject.duration)
				color: "#FFFFFF"
				style: Text.Raised
				styleColor: "#111111"

			}

			Item {
				Layout.fillWidth: true
			}
		}
	}
}

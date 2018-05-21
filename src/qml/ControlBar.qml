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
			spacing: 2
			
			ControlBarButton {
				iconName: mpvObject.paused ? "play" : "pause"
				onClicked: mpvObject.playPause()
			}

			Label {
				Layout.fillWidth: true
				text: "" + mpvPlayer.formatShortTime(mpvObject.position) + " / " + mpvPlayer.formatShortTime(mpvObject.duration)
				horizontalAlignment: Text.AlignHCenter
				color: "#FFFFFF"
				style: Text.Raised
				styleColor: "#111111"

			}

			ControlBarButton {
				iconName: window.isFullscreen ? "fs-checked" : "fs"
				onClicked: window.toggleFullscreen()
			}

		}

		Item {
			Layout.fillWidth: true
			implicitHeight: 8
		}
	}
}

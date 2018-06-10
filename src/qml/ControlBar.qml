import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

MouseArea {
	implicitHeight: columnLayout.implicitHeight
	hoverEnabled: true

	property alias seekSlider: seekSlider

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
				iconName: mpvObject.isPlaying ? "pause" : "play"
				onClicked: mpvObject.playPause()
			}

			Label {
				Layout.fillWidth: true
				text: "" + mpvObject.positionStr + " / " + mpvObject.durationStr
				horizontalAlignment: Text.AlignHCenter
				color: "#FFFFFF"
				style: Text.Raised
				styleColor: "#111111"

			}

			ControlBarButton {
				iconName: "playlist"
				onClicked: appActions.togglePlaylistAction.trigger()
			}

			ControlBarButton {
				iconName: window.isFullscreen ? "fs-checked" : "fs"
				onClicked: appActions.toggleFullscreenAction.trigger()
			}

		}

		Item {
			Layout.fillWidth: true
			implicitHeight: 8
		}
	}
}

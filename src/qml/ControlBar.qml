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
		spacing: 0

		SeekbarSlider {
			id: seekSlider
			Layout.fillWidth: true
		}

		RowLayout {
			Layout.preferredHeight: 32
			Layout.fillWidth: true
			
			ToolButton {
				iconSource: mpvObject.paused ? "qrc:icons/media-playback-start.png" : "qrc:icons/media-playback-pause.png"
				// iconSource: mpvObject.paused ? "media-playback-start" : "media-playback-pause"
				onClicked: mpvObject.playPause()
			}

			Label {
				text: "" + mpvPlayer.formatShortTime(mpvObject.position) + " / " + mpvPlayer.formatShortTime(mpvObject.duration)
			}

			Item {
				Layout.fillWidth: true
			}
		}
	}
}

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

MouseArea {
	id: controlBar
	implicitHeight: columnLayout.implicitHeight
	hoverEnabled: true

	property alias seekSlider: seekSlider
	property bool compactMode: width <= 580 // TODO DPI

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
				action: appActions.playPauseAction
			}

			ControlBarButton {
				visible: !controlBar.compactMode
				iconName: "previous"
				action: appActions.previousVideoAction
			}

			ControlBarButton {
				visible: !controlBar.compactMode
				iconName: "next"
				action: appActions.nextVideoAction
			}

			ControlBarButton {
				iconName: {
					// console.log('mpvObject.volume', mpvObject.volume)
					if (mpvObject.muted) {
						return "volume-mute"
					} else {
						if (mpvObject.volume >= 100) {
							return "volume-100"
						} else if (mpvObject.volume >= 66) {
							return "volume-high"
						} else if (mpvObject.volume >= 1) {
							return "volume-low"
						} else {
							return "volume-0"
						}
					}
				}
				iconSource: {
					return "qrc:icons/Tethys/" + iconName + ".png"
				}
				action: appActions.volumeMuteAction
			}

			VolumeSlider {
				id: volumeSeekbar
				visible: !controlBar.compactMode
			}

			Item { Layout.fillWidth: true }

			ControlBarButton {
				text: "" + mpvObject.positionStr + " / " + (config.showTimeLeft ? "-" + mpvObject.timeLeftStr : mpvObject.durationStr)
				onClicked: config.showTimeLeft = !config.showTimeLeft
			}

			Item { Layout.fillWidth: true }

			ControlBarButton {
				visible: !controlBar.compactMode
				iconName: "audio"
				text: "" + mpvObject.aid + " / " + mpvObject.numAudioTracks
				onClicked: mpvObject.nextAudioTrack()
			}

			ControlBarButton {
				visible: !controlBar.compactMode
				iconName: "sub"
				text: "" + mpvObject.sid + " / " + mpvObject.numSubTracks
				onClicked: mpvObject.nextSubTrack()
			}

			ControlBarButton {
				visible: !controlBar.compactMode
				iconName: "playlist"
				action: appActions.togglePlaylistAction
			}

			ControlBarButton {
				iconName: window.isFullscreen ? "fs-checked" : "fs"
				action: appActions.toggleFullscreenAction
			}

		}

		Item {
			Layout.fillWidth: true
			implicitHeight: 8
		}
	}
}

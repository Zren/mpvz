import QtQuick 2.1
import QtQuick.Controls 1.4

Menu {
	id: contextMenu
	
	Menu {
		title: "Open"

		MenuItem { action: appActions.openFileAction }
	}

	MenuSeparator {}

	Menu {
		title: "Play"

		MenuItem { action: appActions.playPauseAction }
		MenuItem { action: appActions.stopAction }
		MenuItem { action: appActions.previousVideoAction }
		MenuItem { action: appActions.nextVideoAction }

		MenuSeparator {}

		Menu {
			title: "Speed"

			MenuItem { action: appActions.resetSpeedAction }

			MenuSeparator {}

			MenuItem { action: appActions.playFasterAction }
			MenuItem { action: appActions.playSlowerAction }
		}

		MenuSeparator {}

		Menu {
			title: "Seek"

			MenuItem { action: appActions.seekBeginningAction }

			MenuSeparator {}

			MenuItem { action: appActions.seekBackwardAction }
			MenuItem { action: appActions.seekForwardAction }
		}
	}

	Menu {
		title: "Video"

		MenuItem { action: appActions.toggleHwdecAction }
		MenuItem { action: appActions.toggle60fpsAction }
	}

	Menu {
		title: "Audio"

		Menu {
			title: "Volume"

			MenuItem { action: appActions.volumeMuteAction }

			MenuSeparator {}

			MenuItem { action: appActions.volumeUpAction }
			MenuItem { action: appActions.volumeDownAction }
		}
	}

	Menu {
		title: "Subtitle"
	}
	
	MenuSeparator {}


	Menu {
		title: "Tools"

		Menu {
			title: "Playlist"

			MenuItem { action: appActions.togglePlaylistAction }
		}

		MenuItem { action: appActions.togglePlaybackInfoAction }
		MenuItem { action: appActions.toggleConsoleViewAction }
	}

	Menu {
		title: "Window"

		MenuItem { action: appActions.toggleFullscreenAction }
	}
}

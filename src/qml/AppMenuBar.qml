import QtQuick 2.1
import QtQuick.Controls 1.4

MenuBar {
	id: menuBar

	Menu {
		title: "File"

		MenuItem { action: appActions.openFileAction }
		MenuItem { action: appActions.openFolderAction }

		Menu {
			id: recentFilesMenu
			title: "Recent Files"
			enabled: items.length > 0
		}

		MenuSeparator {}

		MenuItem { action: appActions.filePropertiesAction }

		MenuItem { action: appActions.exitAction }
	}




	Menu {
		title: "View"

		MenuItem { action: appActions.hideMenuAction }

		Menu {
			title: "Presets"

			MenuItem { action: appActions.minimalPresetAction }
			MenuItem { action: appActions.compactPresetAction }
			MenuItem { action: appActions.normalPresetAction }
			MenuItem { action: appActions.pictureInPictureAction }
		}

		MenuSeparator {}

		MenuItem { action: appActions.toggleFullscreenAction }

		MenuSeparator {}

		Menu {
			title: "On Top"
			MenuItem { action: appActions.neverOnTopAction }
			MenuItem { action: appActions.alwaysOnTopAction }
			MenuItem { action: appActions.onTopWhilePlayingAction }
		}

		MenuSeparator {}

		MenuItem { action: appActions.optionsAction }
	}



	Menu {
		title: "Play"

		MenuItem { action: appActions.playPauseAction }
		MenuItem { action: appActions.stopAction }

		MenuSeparator {}

		Menu {
			title: "Volume"

			MenuItem { action: appActions.volumeMuteAction }

			MenuSeparator {}

			MenuItem { action: appActions.volumeUpAction }
			MenuItem { action: appActions.volumeDownAction }
		}
	}




	Menu {
		title: "Navigate"

		MenuItem { action: appActions.previousVideoAction }
		MenuItem { action: appActions.nextVideoAction }

		MenuSeparator {}

		MenuItem { action: appActions.seekBackwardAction }
		MenuItem { action: appActions.seekForwardAction }

		MenuSeparator {}

		MenuItem { action: appActions.stepBackwardAction }
		MenuItem { action: appActions.stepForwardAction }
	}



	Menu {
		title: "Help"

		MenuItem { action: appActions.homePageAction }

		MenuSeparator {}

		MenuItem { action: appActions.aboutAction }
	}
}

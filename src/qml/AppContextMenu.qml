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

}

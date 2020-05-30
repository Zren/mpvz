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

		// MenuItem {
		//     text: "Properties"
		//     shortcut: "Shift+F10"
		// }

		MenuItem {
			text: "Exit"
			shortcut: "Alt+X"
			onTriggered: Qt.quit()
		}
	}




	Menu {
		title: "View"

		MenuItem {
			text: "Hide Menu"
			shortcut: "Ctrl+0"
			checkable: true
			checked: window.hideMenuBar
			onTriggered: {
				window.hideMenuBar = !window.hideMenuBar
			}
		}

		Menu {
			title: "Presets"

			MenuItem {
				text: "Minimal"
				shortcut: "F1"
				onTriggered: {
					window.pictureInPicture = false
					window.hideBorders = true
					window.hideMenuBar = true
				}
			}

			MenuItem {
				text: "Compact"
				shortcut: "F2"
				onTriggered: {
					window.pictureInPicture = false
					window.hideBorders = false
					window.hideMenuBar = true
				}
			}

			MenuItem {
				text: "Normal"
				shortcut: "F3"
				onTriggered: {
					window.pictureInPicture = false
					window.hideBorders = false
					window.hideMenuBar = false
				}
			}

			MenuItem {
				text: "Picture In Picture"
				shortcut: "F4"
				onTriggered: {
					window.pictureInPicture = true
				}
			}
		}

		MenuSeparator {}

		MenuItem { action: appActions.toggleFullscreenAction }

		MenuSeparator {}

		Menu {
			title: "On Top"

			MenuItem {
				text: "Never"
				shortcut: window.alwaysOnTop == 'always' ? "Ctrl+A" : null
				checkable: true
				checked: window.alwaysOnTop == 'never'
				onTriggered: window.alwaysOnTop = 'never'
			}

			MenuItem {
				text: "Always"
				shortcut: window.alwaysOnTop == 'never' ? "Ctrl+A" : null
				checkable: true
				checked: window.alwaysOnTop == 'always'
				onTriggered: window.alwaysOnTop = 'always'
			}

			MenuItem {
				text: "While Playing"
				checkable: true
				checked: window.alwaysOnTop == 'whilePlaying'
				onTriggered: window.alwaysOnTop = 'whilePlaying'
			}
		}

		MenuSeparator {}

		MenuItem {
			text: "Options"
			shortcut: "O"
		}
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

		MenuItem {
			text: "Home Page"
		}

		MenuSeparator {}

		MenuItem {
			text: "About"
		}
	}
}

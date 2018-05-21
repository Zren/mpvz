import QtQuick 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0

MenuBar {
	id: menuBar

	Menu {
		title: "File"

		// MenuItem {
		//     text: "Quick Open File..."
		//     shortcut: "Ctrl+Q"
		//     onTriggered: openFileDialog.open()
		// }

		// MenuSeparator {}

		MenuItem {
			text: "Open File..."
			shortcut: "Ctrl+O"
			// onTriggered: openFileDialog.open()
		}

		// MenuItem {
		//     text: "Open Directory..."
		// }

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
				shortcut: "1"
				onTriggered: {
					window.bordersVisible = false
					window.titleBarVisible = false
					window.menuBarVisible = false
					window.seekBarVisible = false
					window.controlBarVisible = false
					window.statusBarVisible = false
				}
			}

			MenuItem {
				text: "Compact"
				shortcut: "2"
				onTriggered: {
					window.bordersVisible = true
					window.titleBarVisible = false
					window.menuBarVisible = false
					window.seekBarVisible = false
					window.controlBarVisible = true
					window.statusBarVisible = false
				}
			}

			MenuItem {
				text: "Normal"
				shortcut: "3"
				onTriggered: {
					window.bordersVisible = true
					window.titleBarVisible = true
					window.menuBarVisible = true
					window.seekBarVisible = true
					window.controlBarVisible = true
					window.statusBarVisible = true
				}
			}
		}

		MenuSeparator {}

		MenuItem {
			text: "Full Screen"
			shortcut: "Ctrl+Return"
			checkable: true
			checked: window.isFullscreen
			onTriggered: window.toggleFullscreen()
		}

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

		MenuItem {
			text: "Play/Pause"
			shortcut: "Space"
			onTriggered: mpvObject.playPause()
		}

		MenuItem {
			text: "Stop"
			shortcut: "."
			// onTriggered: mpvObject.stop()
		}

		MenuSeparator {}

		Menu {
			title: "Volume"

			MenuItem {
				text: "Up"
				shortcut: "Up"
				// onTriggered: video.volume = Math.min(1, video.volume + 0.1) // +10%
			}

			MenuItem {
				text: "Down"
				shortcut: "Down"
				// onTriggered: video.volume = Math.max(0, video.volume - 0.1) // -10%
			}

			MenuItem {
				text: "Mute"
				shortcut: "Ctrl+M"
				// onTriggered: video.muted = !video.muted
			}
		}
	}




	Menu {
		title: "Navigate"

		MenuItem {
			text: "Previous"
			shortcut: "PgUp"
			onTriggered: mpvPlayer.previousVideo()
		}

		MenuItem {
			text: "Next"
			shortcut: "PgDown"
			onTriggered: mpvPlayer.nextVideo()
		}

		MenuSeparator {}

		MenuItem {
			text: "Seek Backward"
			shortcut: "Left"
			onTriggered: mpvPlayer.seekBackward()
		}

		MenuItem {
			text: "Seek Forward"
			shortcut: "Right"
			onTriggered: mpvPlayer.seekForward()
		}
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

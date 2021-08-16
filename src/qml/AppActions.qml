import QtQuick 2.1
import QtQuick.Controls 1.4

QtObject {

	//--- Open
	property Action openFileAction: Action {
		text: "File"
		shortcut: "Ctrl+F"
		onTriggered: mpvPlayer.selectFile()
	}
	property Action openFolderAction: Action {
		text: "Folder"
		shortcut: "Ctrl+G"
		onTriggered: mpvPlayer.selectFolder()
	}
	property Action filePropertiesAction: Action {
		text: "Properties"
		shortcut: "Shift+F10"
		enabled: false
		// onTriggered: 
	}
	property Action exitAction: Action {
		text: "Exit"
		shortcut: "Alt+X"
		onTriggered: Qt.quit()
	}

	//--- Play
	property Action playPauseAction: Action {
		text: "Play/Pause"
		shortcut: "Space"
		onTriggered: mpvObject.playPause()
	}

	property Action stopAction: Action {
		text: "Stop"
		// shortcut: "."
		onTriggered: mpvObject.stop()
	}

	property Action previousVideoAction: Action {
		text: "Previous"
		shortcut: "PgUp"
		onTriggered: mpvPlayer.previousVideo()
	}

	property Action nextVideoAction: Action {
		text: "Next"
		shortcut: "PgDown"
		onTriggered: mpvPlayer.nextVideo()
	}

	//--- Play > Speed
	property Action resetSpeedAction: Action {
		text: "Reset"
		shortcut: "Backspace"
		onTriggered: mpvObject.resetSpeed()
	}
	// property Action resetSpeedAction2: Action { shortcut: "="; onTriggered: mpvObject.resetSpeed(); }

	property Action playFasterAction: Action {
		text: "+10%"
		shortcut: "+"
		onTriggered: mpvObject.speedUp()
	}
	property Action playFasterAction2: Action { shortcut: "="; onTriggered: mpvObject.speedUp(); }

	property Action playSlowerAction: Action {
		text: "-10%"
		shortcut: "-"
		onTriggered: mpvObject.speedDown()
	}

	property Action halfSpeedAction: Action {
		text: "/2"
		shortcut: "["
		onTriggered: mpvObject.halfSpeed()
	}
	property Action doubleSpeedAction: Action {
		text: "x2"
		shortcut: "]"
		onTriggered: mpvObject.doubleSpeed()
	}

	//--- Play > Seek
	property Action seekBeginningAction: Action {
		text: "Beginning"
		shortcut: "Home"
		onTriggered: mpvPlayer.seekBeginning()
	}

	property Action seekBackwardAction: Action {
		text: "-5 sec"
		shortcut: "Left"
		onTriggered: mpvPlayer.seekBackward()
	}

	property Action seekForwardAction: Action {
		text: "+5 sec"
		shortcut: "Right"
		onTriggered: mpvPlayer.seekForward()
	}

	property Action stepBackwardAction: Action {
		text: "Prev Frame"
		shortcut: ","
		onTriggered: mpvObject.stepBackward()
	}

	property Action stepForwardAction: Action {
		text: "Next Frame"
		shortcut: "."
		onTriggered: mpvObject.stepForward()
	}

	//--- Video
	property Action toggleHwdecAction: Action {
		text: "hwdec"
		shortcut: "Ctrl+H"
		checkable: true
		checked: mpvObject.isUsingHwdec
		onTriggered: mpvObject.toggleHwdec()
	}
	property Action toggle60fpsAction: Action {
		text: "60fps"
		checkable: true
		checked: config.do60fps
		onTriggered: {
			if (config.do60fps) {
				mpvObject.command(["vf", "clr", ""])
			} else {
				mpvObject.command(["vf", "set", "lavfi=\"fps=fps=60:round=down\""])
			}
			config.do60fps = !config.do60fps
		}
	}
	property Action contrastDownAction: Action {
		text: "Contrast Down"
		shortcut: "1"
		onTriggered: mpvObject.contrastDown()
	}
	property Action contrastUpAction: Action {
		text: "Contrast Up"
		shortcut: "2"
		onTriggered: mpvObject.contrastUp()
	}
	property Action brightnessDownAction: Action {
		text: "Brightness Down"
		shortcut: "3"
		onTriggered: mpvObject.brightnessDown()
	}
	property Action brightnessUpAction: Action {
		text: "Brightness Up"
		shortcut: "4"
		onTriggered: mpvObject.brightnessUp()
	}
	property Action gammaDownAction: Action {
		text: "Gamma Down"
		shortcut: "5"
		onTriggered: mpvObject.gammaDown()
	}
	property Action gammaUpAction: Action {
		text: "Gamma Up"
		shortcut: "6"
		onTriggered: mpvObject.gammaUp()
	}
	property Action saturationDownAction: Action {
		text: "Saturation Down"
		shortcut: "7"
		onTriggered: mpvObject.saturationDown()
	}
	property Action saturationUpAction: Action {
		text: "Saturation Up"
		shortcut: "8"
		onTriggered: mpvObject.saturationUp()
	}
	property Action nextVideoTrackAction: Action {
		text: "Next Video Track"
		shortcut: "_"
		onTriggered: mpvObject.nextVideoTrack()
	}

	//--- Audio
	property Action nextAudioTrackAction: Action {
		text: "Next Audio Track"
		shortcut: "#"
		onTriggered: mpvObject.nextAudioTrack()
	}

	//--- Audio > Volume
	property Action volumeMuteAction: Action {
		text: "Mute"
		shortcut: "M"
		checkable: true
		checked: mpvObject.muted
		onTriggered: mpvObject.toggleMute()
	}
	property Action volumeUpAction: Action {
		text: "+2 %"
		shortcut: "Up"
		onTriggered: mpvObject.volumeUp()
	}
	property Action volumeDownAction: Action {
		text: "-2 %"
		shortcut: "Down"
		onTriggered: mpvObject.volumeDown()
	}
	property Action volumeUpAction2: Action { shortcut: "0"; onTriggered: volumeUpAction.trigger() }
	property Action volumeDownAction2: Action { shortcut: "9"; onTriggered: volumeDownAction.trigger() }

	//--- Subtitle
	property Action nextSubTrackAction: Action {
		text: "Next Subtitle Track"
		shortcut: ""
		onTriggered: mpvObject.nextSubTrack()
	}

	//--- Tools
	property Action toggleConsoleViewAction: Action {
		text: "Console"
		shortcut: "`"
		checkable: true
		checked: config.showConsole
		onTriggered: config.showConsole = !config.showConsole
	}
	property Action togglePlaybackInfoAction: Action {
		text: "Playback Information"
		shortcut: "Tab"
		checkable: true
		checked: config.showPlaybackInfo
		onTriggered: config.showPlaybackInfo = !config.showPlaybackInfo
	}
	property Action togglePlaybackInfoAction2: Action { shortcut: "I"; onTriggered: togglePlaybackInfoAction.trigger() }


	property Action optionsAction: Action {
		text: "Options"
		shortcut: "O"
		enabled: false
		// onTriggered:
	}

	//--- Tools > Playlist
	property Action togglePlaylistAction: Action {
		text: "Show / Hide"
		shortcut: "L"
		onTriggered: sidebar.togglePlaylist()
	}

	//--- Window
	property Action toggleFullscreenAction: Action {
		text: "Toggle Fullscreen"
		shortcut: "Alt+Enter"
		checkable: true
		checked: window.isFullscreen
		onTriggered: window.toggleFullscreen()
	}
	property Action toggleFullscreenAction2: Action { shortcut: "F"; onTriggered: toggleFullscreenAction.trigger() }

	//--- View
	property Action hideMenuAction: Action {
		text: "Hide Menu"
		shortcut: "Ctrl+0"
		checkable: true
		checked: window.hideMenuBar
		onTriggered: {
			window.hideMenuBar = !window.hideMenuBar
		}
	}

	//--- View > Presets
	property Action minimalPresetAction: Action {
		text: "Minimal"
		shortcut: "F1"
		onTriggered: {
			window.pictureInPicture = false
			window.hideBorders = true
			window.hideMenuBar = true
		}
	}
	property Action compactPresetAction: Action {
		text: "Compact"
		shortcut: "F2"
		onTriggered: {
			window.pictureInPicture = false
			window.hideBorders = false
			window.hideMenuBar = true
		}
	}
	property Action normalPresetAction: Action {
		text: "Normal"
		shortcut: "F3"
		onTriggered: {
			window.pictureInPicture = false
			window.hideBorders = false
			window.hideMenuBar = false
		}
	}
	property Action pictureInPictureAction: Action {
		text: "Picture In Picture"
		shortcut: "F4"
		onTriggered: {
			window.pictureInPicture = true
		}
	}

	//--- View > On Top
	property Action neverOnTopAction: Action {
		text: "Never"
		shortcut: window.alwaysOnTop == 'always' ? "Ctrl+A" : null
		checkable: true
		checked: window.alwaysOnTop == 'never'
		onTriggered: window.alwaysOnTop = 'never'
	}

	property Action alwaysOnTopAction: Action {
		text: "Always"
		shortcut: window.alwaysOnTop == 'never' ? "Ctrl+A" : null
		checkable: true
		checked: window.alwaysOnTop == 'always'
		onTriggered: window.alwaysOnTop = 'always'
	}

	property Action onTopWhilePlayingAction: Action {
		text: "While Playing"
		checkable: true
		checked: window.alwaysOnTop == 'whilePlaying'
		onTriggered: window.alwaysOnTop = 'whilePlaying'
	}

	//--- Help
	property Action homePageAction: Action {
		text: "Home Page"
		onTriggered: Qt.openUrlExternally('https://github.com/Zren/mpvz')
	}
	property Action aboutAction: Action {
		text: "About"
		enabled: false
		// onTriggered: 
	}
}

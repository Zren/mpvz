import QtQuick 2.1
import QtQuick.Controls 1.4

QtObject {

	//--- Open
	property Action openFileAction: Action {
		text: "File"
		shortcut: "Ctrl+F"
		// onTriggered: 
	}
	property Action openFolderAction: Action {
		text: "Folder"
		shortcut: "Ctrl+G"
		// onTriggered: 
	}

	//--- Play
	property Action playPauseAction: Action {
		text: "Play/Pause"
		shortcut: "Space"
		onTriggered: mpvObject.playPause()
	}

	property Action stopAction: Action {
		text: "Stop"
		shortcut: "."
		// onTriggered: mpvObject.stop()
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
		onTriggered: {
			mpvObject.speed = 1
		}
	}

	property Action playFasterAction: Action {
		text: "+10%"
		shortcut: "+"
		onTriggered: {
			mpvObject.speed += 0.1
		}
	}

	property Action playSlowerAction: Action {
		text: "-10%"
		shortcut: "-"
		onTriggered: {
			mpvObject.speed -= 0.1
		}
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

	//--- Tools
	property Action togglePlaybackInfoAction: Action {
		text: "Playback Information"
		shortcut: "Tab"
		checkable: true
		checked: config.showPlaybackInfo
		onTriggered: config.showPlaybackInfo = !config.showPlaybackInfo
	}

	//--- Window
	property Action toggleFullscreenAction: Action {
		text: "Toggle Fullscreen"
		shortcut: "Alt+Enter"
		checkable: true
		checked: window.isFullscreen
		onTriggered: window.toggleFullscreen()
	}
}

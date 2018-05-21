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

	//--- Window
	property Action toggleFullscreenAction: Action {
		text: "Toggle Fullscreen"
		shortcut: "Alt+Enter"
		checkable: true
		checked: window.isFullscreen
		onTriggered: window.toggleFullscreen()
	}
}

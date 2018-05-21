import QtQuick 2.0
import QtQuick.Window 2.0

import mpvz 1.0
import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtMultimedia 5.7
import Qt.labs.folderlistmodel 2.1

Window {
	id: window

	objectName: "mainWindow"
	property var commandLineUrls: []

	width: 1280
	height: 720
	visible: true

	readonly property bool isFullscreen: visibility == 5 // QWindow::FullScreen
	readonly property bool isPlaying: !mpvPlayer.mpvObject.paused

	onIsPlayingChanged: updateAlwaysOnTopFlag()
	
	property bool bordersVisible: true
	property string alwaysOnTop: 'whilePlaying' // 'never', 'always', 'whilePlaying'
	
	onAlwaysOnTopChanged: updateAlwaysOnTopFlag()
	onBordersVisibleChanged: setWindowFlag(!bordersVisible, Qt.FramelessWindowHint)
	
	function setWindowFlag(flagIt, flag) {
		if (flagIt) {
			window.flags |= flag; // Add the flag
		} else {
			window.flags = window.flags & ~flag; // Remove the flag
		}
	}

	function updateAlwaysOnTopFlag() {
		var flagIt;
		if (alwaysOnTop == 'never') {
			flagIt = false;
		} else if (alwaysOnTop == 'always') {
			flagIt = true;
		} else if (isPlaying) { // 'whilePlaying'
			flagIt = true;
		} else { // !isPlaying + 'whilePlaying'
			flagIt = false;
		}

		setWindowFlag(flagIt, Qt.WindowStaysOnTopHint)
	}

	MpvPlayer {
		id: mpvPlayer
		anchors.fill: parent
	}

	function toggleFullscreen() {
		if (window.isFullscreen) {
			window.show()
		} else {
			window.showFullScreen()
		}
	}

	Timer {
		running: true
		interval: 50
		onTriggered: {
			console.log('app.urls', app.urls)
			if (app.urls.length >= 1) {
				mpvPlayer.mpvObject.loadFile(app.urls[0])
				console.log('loadFile', app.urls[0])
			}
		}
	}
}

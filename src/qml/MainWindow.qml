import QtQuick 2.0
import QtQuick.Window 2.0

import mpvz 1.0
import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Qt.labs.folderlistmodel 2.1

AppWindow {
	id: window

	objectName: "mainWindow"
	property var commandLineUrls: []

	width: {
		if (videoLoaded) {
			if (pictureInPicture) {
				return pipWidth
			} else {
				return videoWidth
			}
		} else {
			return 1280
		}
	}
	height: {
		if (videoLoaded) {
			if (pictureInPicture) {
				return pipHeight
			} else {
				return videoHeight + (menuBarVisible ? menuBar.__contentItem.height : 0)
			}
		} else {
			return 720
		}
	}
	property bool videoLoaded: mpvPlayer.mpvObject.playlistCount >= 1 && videoWidth > 0 && videoHeight > 0
	property int videoWidth: mpvPlayer.mpvObject.dwidth
	property int videoHeight: mpvPlayer.mpvObject.dheight

	QtObject {
		id: config
		property bool autoplayNextFile: true
		property bool showPlaybackInfo: false
		property bool showConsole: false
		property bool do60fps: false
		property bool showTimeLeft: false
	}

	visible: true

	color: "#000"

	title: {
		var s = ""
		if (mpvObject.mediaTitle) {
			s += mpvObject.mediaTitle
			s += " - "
		}

		s += "mpvz"
		return s
	}

	readonly property alias mpvObject: mpvPlayer.mpvObject
	readonly property alias sidebar: mpvPlayer.sidebar
	readonly property bool isMaximized: visibility == 4 // QWindow::Maximized
	readonly property bool isFullscreen: visibility == 5 // QWindow::FullScreen
	readonly property bool isPlaying: !mpvPlayer.mpvObject.paused

	onIsPlayingChanged: updateAlwaysOnTopFlag()
	
	property bool intialized: false
	menuBarVisible: !hideMenuBar && !isFullscreen && !pictureInPicture
	property bool hideMenuBar: true

	readonly property bool bordersVisible: !hideBorders && !pictureInPicture
	property bool hideBorders: false
	property string alwaysOnTop: 'never' // 'never', 'always', 'whilePlaying'

	property bool pictureInPicture: false
	property int pipWidth: videoLoaded ? pipHeight * videoWidth/videoHeight : 480
	property int pipHeight: 270
	property int pipMargin: 10
	property point beforePipPoint: Qt.point(0, 0)
	property int beforePipVisibility: 0
	onPictureInPictureChanged: {
		if (pictureInPicture) {
			beforePipVisibility = visibility
			visibility = 2 // QWindow::Windowed
			beforePipPoint = Qt.point(x, y)
			x = Screen.desktopAvailableWidth - pipWidth - pipMargin
			y = Screen.desktopAvailableHeight - pipHeight - pipMargin
		} else {
			visibility = beforePipVisibility
			x = beforePipPoint.x
			y = beforePipPoint.y
			beforePipPoint = Qt.point(0, 0)
			beforePipVisibility = 0
		}
		updateAlwaysOnTopFlag()
	}

	onAlwaysOnTopChanged: updateAlwaysOnTopFlag()
	onBordersVisibleChanged: updateFramelessWindowFlag()

	Component.onCompleted: {
		updateFramelessWindowFlag()
	}

	function setWindowFlag(flagIt, flag) {
		if (flagIt) {
			window.flags |= flag // Add the flag
		} else {
			window.flags = window.flags & ~flag // Remove the flag
		}
	}

	function updateFramelessWindowFlag() {
		setWindowFlag(!bordersVisible, Qt.FramelessWindowHint)
	}

	function updateAlwaysOnTopFlag() {
		var flagIt
		if (pictureInPicture) {
			flagIt = true
		} else if (alwaysOnTop == 'never') {
			flagIt = false
		} else if (alwaysOnTop == 'always') {
			flagIt = true
		} else if (isPlaying) { // 'whilePlaying'
			flagIt = true
		} else { // !isPlaying + 'whilePlaying'
			flagIt = false
		}

		setWindowFlag(flagIt, Qt.WindowStaysOnTopHint)
	}


	AppActions { id: appActions }
	AppContextMenu { id: contextMenu }
	AppMenuBar { id: appMenuBar }
	menuBar: appMenuBar

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
			if (app.urls.length >= 1) {
				mpvPlayer.mpvObject.loadFile(app.urls[0])
			}
		}
	}
}

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1

import mpvz 1.0

Item {
	id: mpvPlayer
	objectName: "mpvPlayer"
	property alias mpvObject: mpvObject
	property alias folderModel: folderModel

	property bool autoplayNextFile: true

	FolderListModel {
		id: folderModel
		// File ext list from: https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua
		nameFilters: [ "*.3gp", "*.avi", "*.flac", "*.flv", "*.m4a", "*.m4v", "*.mkv", "*.mp3", "*.mp4", "*.mpeg", "*.mpg", "*.ogg", "*.ogm", "*.ogv", "*.opus", "*.rmvb", "*.wav", "*.webm", "*.wma", "*.wmv" ]
		sortField :  "Name"
		showDotAndDotDot: false
		showDirs: false

		property string currentFileName: ""
		function setCurrentFile(filePath) {
			console.log('filePath', filePath)
			var dirPath = getDirPath(filePath)
			console.log('getDirPath', dirPath)
			folderModel.folder = dirPath
			var fileName = basename(filePath)
			console.log('basename', fileName)
			folderModel.currentFileName = fileName
		}

		onCountChanged: {
			console.log('folderModel.count', count)
		}

		property var mpvConnection: Connections {
			target: mpvObject
			onFileLoaded: {
				var filePath = mpvObject.getProperty('path')
				folderModel.setCurrentFile(filePath)
			}
			onFileEnded: {
				console.log('onFileEnded')
				if (mpvObject.playlistCount == 1 && folderModel.count >= 2 && autoplayNextFile) {
					console.log('mpvObject.playlistCount == 1 && folderModel.count >= 2 && autoplayNextFile')
					var currentFilePath = folderModel.folder + '/' + folderModel.currentFileName
					console.log('currentFilePath', currentFilePath)
					var currentFileIndex = folderModel.indexOf(currentFilePath)
					console.log('currentFileIndex', currentFileIndex)
					if (currentFileIndex >= 0 && currentFileIndex < folderModel.count-1) {
						var nextFilePath = folderModel.get(currentFileIndex+1, 'filePath')
						mpvObject.loadFile(nextFilePath)
					}
				}
			}
		}
	}

	MpvObject {
		id: mpvObject
		objectName: "mpvObject"
		anchors.fill: parent

		// onMpvUpdated: console.log('onMpvUpdated', Date.now())
		// onPositionChanged: console.log('onPositionChanged', value)
		onDurationChanged: console.log('onDurationChanged', value)
		onVolumeChanged: console.log('onVolumeChanged', value)

		function toggleMute() {
			muted = !muted
			if (muted) {
				osd.show("Muted")
			} else {
				osd.show("Volume: " + volume + " %")
			}
		}

		function volumeUp() {
			volume = Math.min(volume + 2, 100)
			osd.show("Volume: " + volume + " %")
		}

		function volumeDown() {
			volume = Math.max(0, volume - 2)
			osd.show("Volume: " + volume + " %")
		}
	}

	MouseArea {
		id: videoMouseArea
		anchors.fill: mpvObject
		acceptedButtons: Qt.AllButtons
		hoverEnabled: true
		property double lastClickToPause: 0
		onClicked: {
			if (mouse.button == Qt.LeftButton) {
				lastClickToPause = Date.now()
				mpvObject.playPause()
			} else if (mouse.button == Qt.RightButton) {
				contextMenu.popup()
			}
		}
		onDoubleClicked: {
			if (mouse.button == Qt.LeftButton) {
				mpvObject.playPause()
				window.toggleFullscreen()
			}
		}
		
		cursorShape: Qt.ArrowCursor
		onPositionChanged: {
			videoMouseArea.cursorShape = Qt.ArrowCursor
			hideCursorTimeout.restart()
		}
		Timer {
			id: hideCursorTimeout
			interval: 700
			onTriggered: videoMouseArea.cursorShape = Qt.BlankCursor
		}
	}

	DropArea {
		id: dropArea
		anchors.fill: parent
		onDropped: {
			if (drop.hasUrls) {
				if (drop.urls.length >= 1) {
					mpvObject.loadFile(drop.urls[0])
					drop.accept(Qt.CopyAction)
				}
			}
		}
	}


	Item {
		id: overlayControls
		anchors.fill: parent
		property bool showOverlay: controlBar.containsMouse || sidebar.containsMouse || hideCursorTimeout.running
		readonly property bool isVisible: opacity > 0
		

		opacity: overlayControls.showOverlay ? 1 : 0
		Behavior on opacity {
			NumberAnimation { duration: overlayControls.showOverlay ? 400 : 0 }
		}

		Rectangle {
			anchors.fill: parent
			
			gradient: Gradient {
				GradientStop { position: 0.0; color: "#FF000000" }
				GradientStop { position: 0.2; color: "#00000000" }
				GradientStop { position: 0.8; color: "#00000000" }
				GradientStop { position: 1.0; color: "#FF000000" }
			}
		}

		ControlBar {
			id: controlBar
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			
			acceptedButtons: overlayControls.showOverlay ? Qt.AllButtons : Qt.NoButton
			propagateComposedEvents: overlayControls.showOverlay ? false : true
		}
		
		Sidebar {
			id: sidebar
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.rightMargin: open ? 0 : -width
			anchors.bottom: controlBar.top
			// anchors.bottom: parent.bottom
			width: 240
			
			property bool open: true
			Behavior on anchors.rightMargin {
				NumberAnimation { duration: 200 }
			}

			Connections {
				target: overlayControls
				onIsVisibleChanged: {
					if (!overlayControls.isVisible) {
						// sidebar.open = false
					}
				}
			}

			acceptedButtons: overlayControls.showOverlay ? Qt.AllButtons : Qt.NoButton
			propagateComposedEvents: overlayControls.showOverlay ? false : true
		}
	}

	Rectangle {
		id: osd
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.margins: 10
		property int padding: 10
		width: padding + osdText.implicitWidth + padding
		height: padding + osdText.implicitHeight + padding

		opacity: osdTimeoutTimer.running ? 1 : 0
		Behavior on opacity {
			NumberAnimation { duration: 250 }
		}

		color: "#BB111111"
		border.width: 1
		border.color: "#BB222222"
		radius: 4

		Text {
			id: osdText
			anchors.centerIn: parent
			color: "#FFFFFF"
			font.pixelSize: 24
		}

		Timer {
			id: osdTimeoutTimer
			interval: 1000
		}

		function show(msg) {
			osdText.text = msg
			osdTimeoutTimer.restart()
		}
	}
	


	function zeroPad(n) {
		var s = n.toString()
		if (s.length == 0) s = "0"
		if (s.length == 1) s = "0" + s
		return s
	}
	function formatTime(t) {
		var totalSeconds = Math.floor(t)
		var seconds = totalSeconds % 60
		var hours = Math.floor(totalSeconds / 3600)
		var minutes = Math.floor((totalSeconds - hours * 3600) / 60)
		return zeroPad(hours) + ":" + zeroPad(minutes) + ":" + zeroPad(seconds)
	}
	function formatShortTime(t) {
		var totalSeconds = Math.floor(t)
		var seconds = totalSeconds % 60
		var hours = Math.floor(totalSeconds / 3600)
		var minutes = Math.floor((totalSeconds - hours * 3600) / 60)
		var s = ""
		if (hours > 0) {
			return hours + ":" + zeroPad(minutes) + ":" + zeroPad(seconds)
		} else {
			return minutes + ":" + zeroPad(seconds)
		}
	}

	function getDirPath(str) {
		var lastSlash = str.lastIndexOf("/")
		if (lastSlash == -1) {
			return 'file://./'
		} else {
			return 'file://' + str.substr(0, lastSlash+1)
		}
	}

	function basename(str) {
		return (str.slice(str.lastIndexOf("/")+1))
	}



	function seekBeginning() {
		controlBar.seekSlider.value = 0
	}

	function seekBackward() {
		controlBar.seekSlider.decrement()
	}

	function seekForward() {
		controlBar.seekSlider.increment()
	}
}

import QtQuick 2.7
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.folderlistmodel 2.1

import mpvz 1.0

Item {
	id: mpvPlayer
	objectName: "mpvPlayer"
	property alias mpvObject: mpvObject
	property alias sidebar: sidebar
	property alias folderModel: folderModel

	property bool shouldAutoplay: false

	FolderListModel {
		id: folderModel
		// File ext list from: https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua
		nameFilters: [ "*.3gp", "*.avi", "*.flac", "*.flv", "*.m4a", "*.m4v", "*.mkv", "*.mp3", "*.mp4", "*.mpeg", "*.mpg", "*.ogg", "*.ogm", "*.ogv", "*.opus", "*.rmvb", "*.wav", "*.webm", "*.wma", "*.wmv" ]
		sortField: "Name"
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
			onFileStarted: {
				console.log('onFileStarted')
			}
			onFileLoaded: {
				console.log('onFileLoaded')
				var filePath = mpvObject.path
				folderModel.setCurrentFile(filePath)
				mpvPlayer.shouldAutoplay = true
			}
			onFileEnded: {
				console.log('onFileEnded', reason)
				if (reason == "eof") {
					if (mpvPlayer.isAutoplayingFolder()) {
						mpvPlayer.playNextFileInFolder()
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
		// onDurationChanged: console.log('onDurationChanged', value)
		// onVolumeChanged: console.log('onVolumeChanged', value)

		function toggleMute() {
			muted = !muted
			showVolumeOsd()
		}
		function showVolumeOsd() {
			if (muted) {
				osd.show("Muted")
			} else {
				osd.show("Volume: " + volume + " %")
			}
		}
		function setVolume(val) {
			volume = Math.max(0, Math.min(val, 100))
			if (muted && volume > 0) {
				muted = false
			} else if (!muted && volume == 0) {
				muted = true
			}
			showVolumeOsd()
		}
		function volumeUp() { setVolume(volume + 2) }
		function volumeDown() { setVolume(volume - 2) }

		function equalizerPropUp(key, label) {
			mpvObject[key] = Math.min(mpvObject[key] + 1, 100)
			console.log(key + 'Up', mpvObject[key])
			equalizer.show(label, mpvObject[key])
		}
		function equalizerPropDown(key, label) {
			mpvObject[key] = Math.max(-100, mpvObject[key] - 1)
			console.log(key + 'Down', mpvObject[key])
			equalizer.show(label, mpvObject[key])
		}
		function contrastUp() { equalizerPropUp('contrast', 'Contrast') }
		function contrastDown() { equalizerPropDown('contrast', 'Contrast') }
		function gammaUp() { equalizerPropUp('gamma', 'Gamma') }
		function gammaDown() { equalizerPropDown('gamma', 'Gamma') }
		function brightnessUp() { equalizerPropUp('brightness', 'Brightness') }
		function brightnessDown() { equalizerPropDown('brightness', 'Brightness') }
		function saturationUp() { equalizerPropUp('saturation', 'Saturation') }
		function saturationDown() { equalizerPropDown('saturation', 'Saturation') }

		function setSpeed(val) {
			speed = val
			osd.show("Speed: " + speed.toFixed(2) + "x")
		}
		function resetSpeed() { setSpeed(1.0) }
		function speedUp() { setSpeed(speed + 0.1) }
		function speedDown() { setSpeed(speed - 0.1) }

		readonly property real positionRatio: position / duration
		readonly property string positionStr: formatShortTime(position)
		readonly property string durationStr: formatShortTime(duration)
		readonly property string stateStr: {
			if (idleActive) {
				return "Idle"
			} else if (paused) {
				return "Paused"
			} else {
				return "Playing"
			}
		}

		// onPausedChanged: console.log('onPausedChanged', paused)
		// onIdleActiveChanged: console.log('onIdleActiveChanged', idleActive)
		// onIsPlayingChanged: console.log('onIsPlayingChanged', isPlaying)
		// onStateStrChanged: console.log('onStateStrChanged', stateStr)
		// onHwdecChanged: console.log('hwdec', hwdec)
		// onHwdecCurrentChanged: console.log('hwdecCurrent', hwdecCurrent)
		// onHwdecInteropChanged: console.log('hwdecInterop', hwdecInterop)

		property int numVideoTracks: 0
		property int numAudioTracks: 0
		property int numSubTracks: 0

		function updateTrackStatus() {
			var trackList = mpvObject.getProperty("track-list")
			// console.log('trackList', JSON.stringify(trackList, null, '\t'))

			var nv = 0, na = 0, ns = 0
			for (var i = 0; i < trackList.length; i++) {
				var track = trackList[i]
				if (track.type == "video") {
					nv += 1
				} else if (track.type == "audio") {
					na += 1
				} else if (track.type == "sub") {
					ns += 1
				}
			}
			numVideoTracks = nv
			numAudioTracks = na
			numSubTracks = ns
		}

		function getTrack(type, id) {
			var trackList = mpvObject.getProperty("track-list")
			for (var i = 0; i < trackList.length; i++) {
				var track = trackList[i]
				if (track.type == type && track.id == id) {
					return track
				}
			}
			return null
		}

		function formatTrackLabel(track) {
			var label = (track.lang ? " [" + track.lang + "]" : "") + (track.title ? " " + track.title : "")
			return label.trim()
		}

		function nextVideoTrack() {
			var nextTrack = ((mpvObject.vid + 1) % (mpvObject.numVideoTracks + 1))
			// console.log('vid', mpvObject.vid, '=>', nextTrack)
			mpvObject.setProperty("vid", nextTrack)

			var trackMsg = ""
			if (mpvObject.aid > 0) {
				var track = getTrack("video", mpvObject.vid)
				trackMsg = "" + mpvObject.vid + "/" + mpvObject.numVideoTracks + " " + formatTrackLabel(track)
			} else {
				trackMsg = "none"
			}
			osd.show("Video Track: " + trackMsg)
		}

		function nextAudioTrack() {
			var nextTrack = ((mpvObject.aid + 1) % (mpvObject.numAudioTracks + 1))
			// console.log('aid', mpvObject.aid, '=>', nextTrack)
			mpvObject.setProperty("aid", nextTrack)

			var trackMsg = ""
			if (mpvObject.aid > 0) {
				var track = getTrack("audio", mpvObject.aid)
				trackMsg = "" + mpvObject.aid + "/" + mpvObject.numAudioTracks + " " + formatTrackLabel(track)
			} else {
				trackMsg = "none"
			}
			osd.show("Audio Track: " + trackMsg)
		}
		function nextSubTrack() {
			var nextTrack = ((mpvObject.sid + 1) % (mpvObject.numSubTracks + 1))
			// console.log('sid', mpvObject.sid, '=>', nextTrack)
			mpvObject.setProperty("sid", nextTrack)

			var trackMsg = ""
			if (mpvObject.sid > 0) {
				var track = getTrack("sub", mpvObject.sid)
				trackMsg = "" + mpvObject.sid + "/" + mpvObject.numSubTracks + " " + formatTrackLabel(track)
			} else {
				trackMsg = "none"
			}
			osd.show("Subtitle Track: " + trackMsg)
		}

		onFileLoaded: {
			updateTrackStatus()
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
		property point prevPos: Qt.point(0, 0)
		property point cursorHiddenPos: Qt.point(0, 0)
		property point clickedWinPos: Qt.point(0, 0)
		property point clickedMousePos: Qt.point(0, 0)
		onEntered: {
			prevPos = Qt.point(mouseX, mouseY)
		}
		onPressed: {
			if (mouse.buttons & Qt.LeftButton == Qt.LeftButton) {
				clickedMousePos = mapToGlobal(mouseX, mouseY)
				clickedWinPos = Qt.point(window.x, window.y)
			}
		}
		onReleased: {
			clickedMousePos = Qt.point(0, 0)
			clickedWinPos = Qt.point(0, 0)
			if (videoMouseArea.cursorShape == Qt.DragMoveCursor) {
				videoMouseArea.cursorShape = Qt.ArrowCursor
			}
		}
		onPositionChanged: {
			var curPos = Qt.point(mouse.x, mouse.y)
			if (mouse.buttons & Qt.LeftButton == Qt.LeftButton) {
				var globalCurPos = mapToGlobal(mouse.x, mouse.y)
				var delta = Qt.point(globalCurPos.x - clickedMousePos.x, globalCurPos.y - clickedMousePos.y)
				var dist = Math.abs(delta.x) + Math.abs(delta.y) // manhattanLength()
				var dragThreshold = 30
				if (dist >= dragThreshold) {
					// videoMouseArea.cursorShape = Qt.DragMoveCursor
					// window.x = clickedWinPos.x + delta.x
					// window.y = clickedWinPos.y + delta.y

					app.dragWindow(window)
				}
			} else {
				var delta = Qt.point(curPos.x - cursorHiddenPos.x, curPos.y - cursorHiddenPos.y)
				var dist = Math.abs(delta.x) + Math.abs(delta.y) // manhattanLength()
				var moveThreshold = 30
				if (dist >= moveThreshold) {
					videoMouseArea.cursorShape = Qt.ArrowCursor
					hideCursorTimeout.restart()
				}
			}

			prevPos = curPos
		}
		onExited: {
			prevPos = Qt.point(0, 0)
		}
		Timer {
			id: hideCursorTimeout
			interval: 700
			onTriggered: {
				videoMouseArea.cursorShape = Qt.BlankCursor
				videoMouseArea.cursorHiddenPos = Qt.point(videoMouseArea.mouseX, videoMouseArea.mouseY)
			}
		}

		property int wheelDelta: 0
		onWheel: {
			wheelDelta += wheel.angleDelta.y
			for (; wheelDelta >= 120; wheelDelta -= 120) wheelUpTick()
			for (; wheelDelta <= -120; wheelDelta += 120) wheelDownTick()
		}
		function wheelUpTick() {
			mpvPlayer.seekBackward()
		}
		function wheelDownTick() {
			mpvPlayer.seekForward()
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

		onIsVisibleChanged: {
			if (isVisible) {
				mpvObject.setProperty('sub-margin-y', controlBar.height + 22)
			} else {
				mpvObject.setProperty('sub-margin-y', 22)
			}
		}
		

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
			anchors.bottom: controlBar.top
			anchors.rightMargin: width * rightMarginRatio
			property real rightMarginRatio: sidebar.open ? 0 : -1
			width: Math.max(240, Math.min(Math.round(parent.width/3), 600))
			
			Behavior on rightMarginRatio {
				NumberAnimation { duration: 100 }
			}

			Connections {
				target: overlayControls
				onIsVisibleChanged: {
					if (!overlayControls.isVisible) {
						sidebar.close()
					}
				}
			}

			acceptedButtons: overlayControls.showOverlay ? Qt.AllButtons : Qt.NoButton
			propagateComposedEvents: overlayControls.showOverlay ? false : true
		}
	}

	Loader {
		id: consoleView
		anchors.fill: parent
		anchors.margins: 10
		anchors.bottomMargin: controlBar.height
		source: "ConsoleView.qml"
		active: config.showConsole
	}

	Loader {
		id: playbackInfo
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 10
		source: "PlaybackInfoView.qml"
		active: config.showPlaybackInfo
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

	Equalizer {
		id: equalizer
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 100

		opacity: equalizerTimeoutTimer.running ? 1 : 0

		Timer {
			id: equalizerTimeoutTimer
			interval: 1000
		}

		function show(label, value) {
			osd.show("" + label + ": " + value)
			equalizerTimeoutTimer.restart()
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

	function previousVideo() {
		if (isAutoplayingFolder()) {
			playPrevFileInFolder()
		} else {
			mpvObject.command(["playlist-prev"])
		}
	}

	function nextVideo() {
		if (isAutoplayingFolder()) {
			playNextFileInFolder()
		} else {
			mpvObject.command(["playlist-next"])
		}
	}

	function isAutoplayingFolder() {
		return mpvObject.playlistCount == 1 && folderModel.count >= 2 && config.autoplayNextFile && mpvPlayer.shouldAutoplay
	}
	function playPrevFileInFolder() {
		if (isAutoplayingFolder()) {
			var currentFilePath = folderModel.folder + '/' + folderModel.currentFileName
			console.log('currentFilePath', currentFilePath)
			var currentFileIndex = folderModel.indexOf(currentFilePath)
			console.log('currentFileIndex', currentFileIndex)
			if (currentFileIndex >= 0 && currentFileIndex > 0) {
				var prevFilePath = folderModel.get(currentFileIndex-1, 'filePath')
				mpvPlayer.shouldAutoplay = false
				mpvObject.loadFile(prevFilePath)
				return true
			}
		}
		return false
	}
	function playNextFileInFolder() {
		if (isAutoplayingFolder()) {
			var currentFilePath = folderModel.folder + '/' + folderModel.currentFileName
			console.log('currentFilePath', currentFilePath)
			var currentFileIndex = folderModel.indexOf(currentFilePath)
			console.log('currentFileIndex', currentFileIndex)
			if (currentFileIndex >= 0 && currentFileIndex < folderModel.count-1) {
				var nextFilePath = folderModel.get(currentFileIndex+1, 'filePath')
				mpvPlayer.shouldAutoplay = false
				mpvObject.loadFile(nextFilePath)
				return true
			}
		}
		return false
	}
}

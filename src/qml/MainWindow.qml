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

	property bool isFullscreen: visibility == 5 // QWindow::FullScreen    

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

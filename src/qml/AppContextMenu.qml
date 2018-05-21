import QtQuick 2.1
import QtQuick.Controls 1.4

Menu {
	id: contextMenu

	MenuItem {
		text: window.isPlaying ? "Pause" : "Play"
		onTriggered: window.togglePlay()
	}

	MenuItem {
		text: "Stop"
		onTriggered: window.stopVideo()
	}

	MenuItem {
		text: "Previous"
		onTriggered: window.previousVideo()
	}

	MenuItem {
		text: "Next"
		onTriggered: window.nextVideo()
	}
}

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

MouseArea {
	id: sidebar
	hoverEnabled: true

	property bool open: false

	Rectangle {
		anchors.fill: parent
		color: "#88111111"
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#BB111111" }
			GradientStop { position: 0.2; color: "#88111111" }
			GradientStop { position: 0.8; color: "#BB111111" }
			GradientStop { position: 1.0; color: "#EE111111" }
		}
	}

	PlaylistView {
		id: playlistView
		anchors.fill: parent
	}

	// ChapterList {
	// 	id: chapterList
	// 	anchors.fill: parent
	// }

	function close() {
		sidebar.open = false
	}

	function togglePlaylist() {
		if (sidebar.open && true) {
			sidebar.close()
		} else {
			sidebar.open = true
		}
	}
}

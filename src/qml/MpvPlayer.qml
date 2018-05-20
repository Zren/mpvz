import QtQuick 2.0
import QtQuick.Controls 1.0

import mpvz 1.0

Item {
	id: mpvPlayer
	objectName: "mpvPlayer"
	property alias mpvObject: mpvObject

	MpvObject {
		id: mpvObject
		objectName: "mpvObject"
		anchors.fill: parent

		MouseArea {
			anchors.fill: parent
		}

		function loadfile(filepath) {
			mpvObject.command(["loadfile", filepath])
		}
	}
}

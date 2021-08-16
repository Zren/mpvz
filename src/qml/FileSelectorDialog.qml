import QtQuick 2.2
import QtQuick.Dialogs 1.1

FileDialog {
	id: fileSelectorDialog
	title: selectFolder ? "Select Folder" : "Open File"
	selectFolder: fileSelectorLoader.selectFolder
	folder: shortcuts.movies
	onAccepted: {
		if (fileUrls.length >= 1) {
			mpvPlayer.loadUrl(fileUrls[0])
		}
		fileSelectorLoader.active = false
	}
	onRejected: {
		fileSelectorLoader.active = false
	}
	Component.onCompleted: visible = true
}

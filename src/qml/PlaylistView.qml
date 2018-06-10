import QtQuick 2.0

SidebarListView {
	title: "Playlist"
	model: mpvObject.playlistCount
	delegate: SidebarListItem {
		function basename(str) {
			return (str.slice(str.lastIndexOf("/")+1))
		}
		readonly property string itemFilename: mpvObject.getPlaylistFilename(index)
		readonly property string itemFileBasename: basename(itemFilename)
		readonly property string itemTitle: mpvObject.getPlaylistTitle(index)

		text: itemFileBasename
		isCurrentItem: mpvObject.playlistPos == index

		onClicked: {
			mpvObject.playlistPos = index
			mpvObject.play()
		}
	}
}

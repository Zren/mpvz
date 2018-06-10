import QtQuick 2.0

SidebarListView {
	title: "Chapters"
	model: mpvObject.chapterListCount
	delegate: SidebarListItem {
		readonly property string chapterTitle: mpvObject.getChapterTitle(index)
		readonly property double chapterStartTime: mpvObject.getChapterTime(index)
		readonly property double chapterEndTime: {
			if (index == mpvObject.chapterListCount - 1) { // Last Chapter
				return mpvObject.duration
			} else {
				return mpvObject.getChapterTime(index + 1)
			}
		}

		text: chapterTitle || ("Chapter #" + (index + 1))
		description: formatShortTime(chapterStartTime) + " ⇒ " + formatShortTime(chapterEndTime)
		isCurrentItem: mpvObject.chapter == index

		onClicked: controlBar.seekSlider.value = chapterStartTime
	}
}

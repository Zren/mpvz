import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0

ScrollView {
	id: scrollView
	clip: true

	default property alias contents: contentLayout.data
	property alias spacing: contentLayout.spacing

	readonly property int viewportWidth: viewport ? viewport.width : width
	readonly property int viewportHeight: viewport ? viewport.height : height

	contentItem: ColumnLayout {
		id: contentLayout
		width: scrollView.viewportWidth
		spacing: 0
	}

	style: ScrollViewStyle {
		id: style
		transientScrollBars: true

		property int horPadding: 3
		property int handleSize: 6
		frame: Item {}
		scrollBarBackground: Rectangle {
			implicitWidth: style.handleSize + style.horPadding * 2
			color: styleData.hovered ? "#33FFFFFF" : "transparent"
		}
		handle: Rectangle {
			x: style.horPadding
			color: "#88FFFFFF"
			implicitWidth: style.handleSize
			radius: style.handleSize
		}
		handleOverlap: 0
	}
}

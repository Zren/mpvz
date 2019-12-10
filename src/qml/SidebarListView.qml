import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ColumnLayout {
	property alias title: heading.text
	property alias model: modelRepeater.model
	property alias delegate: modelRepeater.delegate
	
	Text {
		id: heading
		color: "#fff"
		font.pixelSize: 12
		font.weight: Font.Bold
		maximumLineCount: 1
		elide: Text.ElideRight
	}
	
	AppScrollView {
		id: scrollView
		Layout.fillWidth: true
		Layout.fillHeight: true

		Repeater {
			id: modelRepeater
		}
	}
}

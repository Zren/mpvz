import QtQuick 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
	id: section
	spacing: 0
	property int indentPadding: 40
	default property alias contentData: contents.data

	property alias heading: heading
	PlaybackInfoText {
		id: heading
		key: "Label"
		value: ""
	}

	ColumnLayout {
		id: contents
		spacing: 0
		Layout.leftMargin: section.indentPadding
	}
}

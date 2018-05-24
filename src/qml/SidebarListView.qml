import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

AppScrollView {
	id: scrollView

	property alias model: modelRepeater.model
	property alias delegate: modelRepeater.delegate

	Repeater {
		id: modelRepeater
	}
}

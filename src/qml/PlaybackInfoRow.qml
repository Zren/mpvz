import QtQuick 2.0
import QtQuick.Layouts 1.0

RowLayout {
	spacing: 30
	Component.onCompleted: {
		for (var i = 0; i < children.length; i++) {
			var child = children[i]
			child.Layout.fillWidth = false
		}
	}
}

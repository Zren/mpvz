import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

MouseArea {
	id: headerBar
	implicitHeight: rowLayout.implicitHeight
	hoverEnabled: true

	RowLayout {
		id: rowLayout
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		Item { Layout.fillWidth: true }

		ControlBarButton {
			iconSource: "qrc:icons/window-close.png"
			action: appActions.exitAction
			tooltipAbove: false
		}

	}
}

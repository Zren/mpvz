import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Shapes 1.10

Item {
	id: equalizerBar

	property int value: 0
	property int minValue: -100
	property int maxValue: 100

	readonly property int totalSteps: maxValue - minValue
	readonly property int currentStep: value - minValue
	readonly property real ratio: currentStep / totalSteps

	property int outlineThickness: 2

	implicitHeight: 24
	implicitWidth: 20
	Layout.fillWidth: true

	Rectangle {
		id: outerOutlineBlack
		anchors.fill: parent
		color: "transparent"
		border.width: outlineThickness
		border.color: "#000"

		Rectangle {
			id: outlineWhite
			anchors.fill: parent
			anchors.margins: parent.border.width
			color: "transparent"
			border.width: outlineThickness
			border.color: "#FFF"

			Rectangle {
				id: innerOutlineBlack
				anchors.fill: parent
				anchors.margins: parent.border.width
				color: "transparent"
				border.width: outlineThickness
				border.color: "#000"
			}

			Rectangle {
				id: slider
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.margins: parent.border.width

				width: parent.width * ratio

				color: "#FFF"
				border.width: outlineThickness
				border.color: "#000"
			}

			Shape {
				id: topCenterTick
				anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.margins: outlineThickness

				width: outlineThickness * 3
				height: outlineThickness * 3

				ShapePath {
					strokeWidth: outlineThickness
					strokeColor: "#000"
					fillColor: "#FFF"
					capStyle: ShapePath.FlatCap

					startX: 0; startY: 0
					PathLine { x: topCenterTick.width/2; y: topCenterTick.height }
					PathLine { x: topCenterTick.width; y: 0 }
				}
			}

			Shape {
				id: bottomCenterTick
				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.margins: outlineThickness

				width: outlineThickness * 3
				height: outlineThickness * 3

				ShapePath {
					strokeWidth: outlineThickness
					strokeColor: "#000"
					fillColor: "#FFF"
					capStyle: ShapePath.FlatCap

					startX: 0; startY: topCenterTick.height
					PathLine { x: topCenterTick.width/2; y: 0 }
					PathLine { x: topCenterTick.width; y: topCenterTick.height }
				}
			}
		}
	}
}

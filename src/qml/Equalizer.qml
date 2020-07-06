import QtQuick 2.0
import QtQuick.Layouts 1.0

GridLayout {
	id: equalizer
	columns: 4
	rowSpacing: 10

	EqualizerLabel { text: "Contrast" }
	ShortcutLabel { text: appActions.contrastDownAction.shortcut }
	EqualizerBar { value: mpvObject.contrast }
	ShortcutLabel { text: appActions.contrastUpAction.shortcut }

	EqualizerLabel { text: "Brightness" }
	ShortcutLabel { text: appActions.brightnessDownAction.shortcut }
	EqualizerBar { value: mpvObject.brightness }
	ShortcutLabel { text: appActions.brightnessUpAction.shortcut }

	EqualizerLabel { text: "Gamma" }
	ShortcutLabel { text: appActions.gammaDownAction.shortcut }
	EqualizerBar { value: mpvObject.gamma }
	ShortcutLabel { text: appActions.gammaUpAction.shortcut }

	EqualizerLabel { text: "Saturation" }
	ShortcutLabel { text: appActions.saturationDownAction.shortcut }
	EqualizerBar { value: mpvObject.saturation }
	ShortcutLabel { text: appActions.saturationUpAction.shortcut }
}

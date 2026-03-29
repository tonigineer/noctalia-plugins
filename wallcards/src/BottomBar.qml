import QtQuick
import qs.Commons
import qs.Widgets

Rectangle {
  id: bottomBar

  required property real shearFactor
  property bool expanded: false

  color: Qt.alpha(Color.mSurface, 0.7)
  height: shortcutRow.height + Style.marginM
  radius: Style.radiusS
  width: expanded ? shortcutRow.width + Style.margin2L : collapsedRow.width + Style.margin2L

  Behavior on width {
    NumberAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }

  transform: Shear {
    xFactor: bottomBar.shearFactor
  }

  // Collapsed — just show toggle hint
  Row {
    id: collapsedRow
    anchors.centerIn: parent
    spacing: Style.marginS
    visible: !bottomBar.expanded

    ShortcutHint { keys: "?"; label: "Shortcuts" }
  }

  // Expanded — full shortcuts
  Row {
    id: shortcutRow
    anchors.centerIn: parent
    spacing: Style.marginL
    visible: bottomBar.expanded

    ShortcutHint { keys: "J / K"; label: "Navigate" }
    ShortcutHint { keys: "H / L"; label: "Jump" }
    ShortcutHint { keys: "Enter"; label: "Apply" }
    ShortcutHint { keys: "Q"; label: "Quit" }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.alpha(Color.mOnSurface, 0.15)
      height: parent.height * 0.6
      width: 1
    }

    ShortcutHint { keys: "SHIFT / H + L"; label: "Card Heighta" }
    ShortcutHint { keys: "SHIFT / J + K"; label: "Card Width" }
    ShortcutHint { keys: "SHIFT / N + P"; label: "Cards Shown" }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.alpha(Color.mOnSurface, 0.15)
      height: parent.height * 0.6
      width: 1
    }

    ShortcutHint { keys: "CTRL / J + K"; label: "Spacing" }
    ShortcutHint { keys: "CTRL / H + L"; label: "Strip Width" }
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.alpha(Color.mOnSurface, 0.15)
      height: parent.height * 0.6
      width: 1
    }

    ShortcutHint { keys: "CTRL / S"; label: "Save" }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.alpha(Color.mOnSurface, 0.15)
      height: parent.height * 0.6
      width: 1
    }

    ShortcutHint { keys: "?"; label: "Hide" }
  }
}

import QtQuick
import qs.Commons
import qs.Widgets

Rectangle {
  id: sideBar

  property bool expanded: false
  property bool hideHelp: true

  color: Qt.alpha(Color.mSurface, 0.9)
  radius: Style.radiusS
  width: expanded ? shortcutColumn.width + Style.margin2L : !hideHelp ? collapsedColumn.width + Style.margin2L : 0
  height: expanded ? shortcutColumn.height + Style.margin2L : !hideHelp ? collapsedColumn.height + Style.margin2L : 0

  Behavior on width {
    NumberAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }
  Behavior on height {
    NumberAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  clip: true

  // Collapsed state
  Column {
    id: collapsedColumn

    anchors.centerIn: parent
    spacing: Style.marginS
    visible: !sideBar.expanded && !sideBar.hideHelp

    ShortcutHint {
      keys: "?"
      label: "Shortcuts"
    }
  }

  // Expanded state
  Column {
    id: shortcutColumn

    anchors.centerIn: parent
    spacing: Style.marginXS
    visible: sideBar.expanded

    // Navigation
    NText {
      color: Qt.alpha(Color.mOnSurface, 0.35)
      font.bold: true
      font.pointSize: Style.fontSizeXXS
      text: "NAVIGATION"
    }
    ShortcutHint {
      keys: "J / K"
      label: "Navigate"
    }
    ShortcutHint {
      keys: "H / L"
      label: "Jump"
    }
    ShortcutHint {
      keys: "R"
      label: "Shuffle"
    }

    // Separator
    Rectangle {
      color: Qt.alpha(Color.mOnSurface, 0.1)
      height: 1
      width: shortcutColumn.width
    }

    // Actions
    NText {
      color: Qt.alpha(Color.mOnSurface, 0.35)
      font.bold: true
      font.pointSize: Style.fontSizeXXS
      text: "ACTIONS"
    }
    ShortcutHint {
      keys: "ENTER"
      label: "Apply + Quit"
    }
    ShortcutHint {
      keys: "SPACE"
      label: "Apply"
    }
    ShortcutHint {
      keys: "ESC / Q"
      label: "Quit"
    }

    // Separator
    Rectangle {
      color: Qt.alpha(Color.mOnSurface, 0.1)
      height: 1
      width: shortcutColumn.width
    }

    // Filters
    NText {
      color: Qt.alpha(Color.mOnSurface, 0.35)
      font.bold: true
      font.pointSize: Style.fontSizeXXS
      text: "FILTERS"
    }
    ShortcutHint {
      keys: "A"
      label: "All"
    }
    ShortcutHint {
      keys: "I"
      label: "Images"
    }
    ShortcutHint {
      keys: "V"
      label: "Videos"
    }
    ShortcutHint {
      keys: "F"
      label: "Color Filter"
    }

    // Separator
    Rectangle {
      color: Qt.alpha(Color.mOnSurface, 0.1)
      height: 1
      width: shortcutColumn.width
    }

    // View
    NText {
      color: Qt.alpha(Color.mOnSurface, 0.35)
      font.bold: true
      font.pointSize: Style.fontSizeXXS
      text: "VIEW"
    }
    ShortcutHint {
      keys: "T"
      label: "Top Bar"
    }
    ShortcutHint {
      keys: "P"
      label: "Live Preview"
    }

    // Separator
    Rectangle {
      color: Qt.alpha(Color.mOnSurface, 0.1)
      height: 1
      width: shortcutColumn.width
    }

    // Layout
    NText {
      color: Qt.alpha(Color.mOnSurface, 0.35)
      font.bold: true
      font.pointSize: Style.fontSizeXXS
      text: "LAYOUT"
    }
    ShortcutHint {
      keys: "SHIFT + H / L"
      label: "Center Height"
    }
    ShortcutHint {
      keys: "SHIFT + J / K"
      label: "Center Width"
    }
    ShortcutHint {
      keys: "SHIFT + N / P"
      label: "Cards Shown"
    }
    ShortcutHint {
      keys: "CTRL + J / K"
      label: "Spacing"
    }
    ShortcutHint {
      keys: "CTRL + H / L"
      label: "Cards Width"
    }

    // Separator
    Rectangle {
      color: Qt.alpha(Color.mOnSurface, 0.1)
      height: 1
      width: shortcutColumn.width
    }

    ShortcutHint {
      keys: "CTRL + S"
      label: "Save Settings"
    }
    ShortcutHint {
      keys: "?"
      label: "Hide"
    }
  }
}

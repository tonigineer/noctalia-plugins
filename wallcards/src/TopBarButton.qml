import QtQuick
import qs.Commons
import qs.Widgets

Rectangle {
  id: root

  property color accentColor: active ? Color.mOnSurface : Color.mOnSurfaceVariant
  property bool active: false
  property string hotkey: ""
  property string icon: ""
  property string label: ""
  property bool pulsing: false

  signal clicked

  border.color: active ? Qt.alpha(accentColor, Style.opacityMedium) : Qt.alpha(Color.mOutline, 0.3)
  border.width: Style.borderS
  color: active ? Qt.alpha(accentColor, 0.15) : Qt.alpha(Color.mOnSurface, 0.06)
  height: Style.margin2L
  radius: Style.radiusM
  width: contentRow.width + Style.margin2M

  Behavior on border.color {
    ColorAnimation {
      duration: Style.animationFast
    }
  }
  Behavior on color {
    ColorAnimation {
      duration: Style.animationFast
    }
  }

  Row {
    id: contentRow

    anchors.centerIn: parent
    spacing: Style.marginXS

    PulsingDot {
      anchors.verticalCenter: parent.verticalCenter
      pulsing: root.pulsing
      visible: root.pulsing
    }
    NIcon {
      color: root.accentColor
      icon: root.icon
      visible: root.icon !== ""
    }
    NText {
      anchors.verticalCenter: parent.verticalCenter
      color: root.accentColor
      text: root.label
      visible: root.label !== ""
    }
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.alpha(root.accentColor, root.active ? 0.2 : 0.06)
      height: Style.marginL
      radius: Style.radiusM
      visible: root.hotkey !== ""
      width: Style.marginL

      NText {
        anchors.centerIn: parent
        color: Qt.alpha(root.accentColor, root.active ? Style.opacityFull : Style.opacityHeavy)
        font.bold: true
        font.pointSize: Style.fontSizeXXS
        text: root.hotkey
      }
    }
  }
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()
  }
}

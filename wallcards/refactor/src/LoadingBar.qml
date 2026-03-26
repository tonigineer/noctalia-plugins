import QtQuick

Rectangle {
  width: 300
  height: 6
  color: "#333"
  radius: 3

  Rectangle {
    id: fill
    height: parent.height
    radius: parent.radius
    color: "white"
    width: 0

    NumberAnimation on width {
      to: 300
      duration: 2000
      easing.type: Easing.OutCubic
    }
  }
}

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth: 670 * Style.uiScaleRatio
  property real contentPreferredHeight: 270 * Style.uiScaleRatio

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"
    ColumnLayout {
      anchors { fill: parent; margins: Style.marginL }
      WeatherCardExtra {
        visible: Settings.data.location.weatherEnabled
        Layout.fillWidth: true
        forecastDays: 7
        showLocation: false
      }
    }
  }
}

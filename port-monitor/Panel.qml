import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root
  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  property real contentPreferredWidth: 380 * Style.uiScaleRatio
  property real contentPreferredHeight: 400 * Style.uiScaleRatio

  readonly property var mainInstance: pluginApi?.mainInstance
  readonly property int portCount: mainInstance?.portCount ?? 0

  ListModel { id: portModel }

  Connections {
    target: root.mainInstance
    function onSortedPortsChanged() { root.rebuildModel() }
  }

  onMainInstanceChanged: rebuildModel()

  function rebuildModel() {
    var ports = root.mainInstance?.sortedPorts ?? []
    for (var i = 0; i < ports.length; i++) {
      var p = ports[i]
      var entry = {
        port: p.port,
        proto: p.proto,
        address: p.address,
        processName: p.processName ?? "",
        pid: p.pid ?? "",
        hasProcess: (p.pid ?? "") !== ""
      }
      if (i < portModel.count) {
        portModel.set(i, entry)
      } else {
        portModel.append(entry)
      }
    }
    while (portModel.count > ports.length) {
      portModel.remove(portModel.count - 1)
    }
  }

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginXL
      }
      spacing: Style.marginL

      // Header
      NText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Style.marginM
        text: {
          if (root.portCount === 0) return pluginApi?.tr("panel.noPorts")
          if (root.portCount === 1) return pluginApi?.tr("bar.onePort")
          return root.portCount + " " + pluginApi?.tr("bar.multiplePorts")
        }
        pointSize: Style.fontSizeL
        font.weight: Font.DemiBold
        color: root.portCount > 0 ? Color.mPrimary : Color.mOnSurfaceVariant
      }

      // Scrollable port list
      NScrollView {
        id: portScrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth

        ColumnLayout {
          id: portColumn
          width: portScrollView.availableWidth
          spacing: Style.marginS

          Repeater {
            model: portModel

            delegate: NBox {
              Layout.fillWidth: true
              Layout.preferredHeight: portRow.implicitHeight + Style.marginM * 2

              RowLayout {
                id: portRow
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginM

                // Port number
                NText {
                  text: pluginApi?.tr("panel.portNumber", { port: model.port })
                  pointSize: Style.fontSizeM
                  font.weight: Font.Bold
                  font.family: Settings.data.ui.fontFixed
                  color: model.proto === "TCP" ? Color.mPrimary : Color.mTertiary
                  Layout.preferredWidth: 60 * Style.uiScaleRatio
                }

                // Protocol badge
                NText {
                  text: model.proto
                  pointSize: Style.fontSizeXS
                  color: Color.mOnSurfaceVariant
                  Layout.preferredWidth: 30 * Style.uiScaleRatio
                }

                // Address + process info
                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: Style.marginXS

                  NText {
                    text: model.address
                    pointSize: Style.fontSizeS
                    font.family: Settings.data.ui.fontFixed
                    color: Color.mOnSurface
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                  }

                  NText {
                    text: model.processName ? pluginApi?.tr("panel.processInfo", { name: model.processName, pid: model.pid }) : pluginApi?.tr("panel.unknownProcess")
                    pointSize: Style.fontSizeS
                    color: model.processName ? Color.mOnSurface : Color.mOnSurfaceVariant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                  }
                }

                // Kill button — user process: kill directly, system: pkexec
                NIcon {
                  icon: model.hasProcess ? "x" : "shield-x"
                  pointSize: Style.fontSizeM
                  color: killArea.containsMouse ? Color.mError : Color.mOnSurfaceVariant
                  Layout.alignment: Qt.AlignVCenter

                  MouseArea {
                    id: killArea
                    anchors.fill: parent
                    anchors.margins: -Style.marginS
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (model.hasProcess) {
                        root.mainInstance?.killProcess(model.pid)
                      } else {
                        root.mainInstance?.killPortElevated(model.port.toString(), model.proto)
                      }
                    }
                  }
                }
              }
            }
          }

          // No ports message
          NText {
            visible: (root.mainInstance?.portList ?? []).length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.marginXL
            Layout.bottomMargin: Style.marginXL
            text: pluginApi?.tr("panel.noPorts")
            pointSize: Style.fontSizeM
            color: Color.mOnSurfaceVariant
          }
        }
      }

      // Footer
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NButton {
          Layout.fillWidth: true
          text: pluginApi?.tr("panel.refresh")
          onClicked: root.mainInstance?.refresh()
        }

        NIconButton {
          icon: "settings"
          onClicked: {
            if (!pluginApi) return
            BarService.openPluginSettings(pluginApi.panelOpenScreen, pluginApi.manifest)
            pluginApi.closePanel(pluginApi.panelOpenScreen)
          }
        }
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Services.System
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  property string iconType: cfg.iconType ?? defaults.iconType ?? "arrow"

  property real contentPreferredWidth: 400 * Style.uiScaleRatio
  property real contentPreferredHeight: Math.min(contentColumn.implicitHeight + Style.marginL * 2, 600 * Style.uiScaleRatio)

  property bool useCustomColors: cfg.useCustomColors ?? defaults.useCustomColors
  property color colorTx: root.useCustomColors && cfg.colorTx || Color.mSecondary
  property color colorRx: root.useCustomColors && cfg.colorRx || Color.mPrimary

  anchors.fill: parent

  Component.onCompleted: {
    if (pluginApi)
      Logger.i("NetworkIndicator", "Panel initialized");
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      id: contentColumn

      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // ── Header ──

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NIcon {
          icon: "activity"
          pointSize: Style.fontSizeXL
          color: Color.mPrimary
          Layout.alignment: Qt.AlignVCenter
        }

        NText {
          text: root.pluginApi?.tr("panel.title")
          pointSize: Style.fontSizeL
          font.weight: Font.Bold
          color: Color.mOnSurface
          Layout.alignment: Qt.AlignVCenter
        }

        Item {
          Layout.fillWidth: true
        }

        NIconButton {
          icon: "settings"
          tooltipText: root.pluginApi?.tr("actions.widget-settings")
          onClicked: {
            const screen = root.pluginApi?.panelOpenScreen;
            if (screen) {
              root.pluginApi.closePanel(screen);
              Qt.callLater(() => BarService.openPluginSettings(screen, root.pluginApi.manifest));
            }
          }
          Layout.alignment: Qt.AlignVCenter
        }

        NIconButton {
          icon: "close"
          tooltipText: root.pluginApi?.tr("panel.close")
          onClicked: {
            const s = root.pluginApi?.panelOpenScreen;
            if (s)
              root.pluginApi.closePanel(s);
          }
          Layout.alignment: Qt.AlignVCenter
        }
      }

      // ── Download (RX) ──

      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: rxGraph.implicitHeight + Style.marginS * 2

        NetworkGraph {
          id: rxGraph
          anchors.fill: parent
          anchors.margins: Style.marginS

          label: root.pluginApi?.tr("panel.download")
          iconName: root.iconType + "-down"
          accentColor: root.colorRx
          history: SystemStatService.rxSpeedHistory
          maxValue: SystemStatService.rxMaxSpeed
          currentSpeed: SystemStatService.rxSpeed
        }
      }

      // ── Upload (TX) ──

      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: txGraph.implicitHeight + Style.marginS * 2

        NetworkGraph {
          id: txGraph
          anchors.fill: parent
          anchors.margins: Style.marginS

          label: root.pluginApi?.tr("panel.upload") ?? ""
          iconName: root.iconType + "-up"
          accentColor: root.colorTx
          history: SystemStatService.txSpeedHistory
          maxValue: SystemStatService.txMaxSpeed
          currentSpeed: SystemStatService.txSpeed
        }
      }
    }
  }

  component NetworkGraph: ColumnLayout {
    id: graphRoot

    required property string label
    required property string iconName
    required property color accentColor
    required property var history
    required property real maxValue
    required property real currentSpeed

    function formatSpeed(bytesPerSec) {
      return (SystemStatService.formatSpeed(bytesPerSec).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s");
    }

    spacing: Style.marginXS

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginXS

      NIcon {
        icon: graphRoot.iconName
        pointSize: Style.fontSizeXS
        color: graphRoot.accentColor
      }

      NText {
        text: graphRoot.label
        pointSize: Style.fontSizeXS
        color: graphRoot.accentColor
        font.weight: Font.Medium
      }

      Item {
        Layout.fillWidth: true
      }

      NText {
        text: graphRoot.formatSpeed(graphRoot.currentSpeed)
        pointSize: Style.fontSizeXS
        color: graphRoot.accentColor
        font.family: Settings.data.ui.fontFixed
      }
    }

    Item {
      Layout.fillWidth: true
      implicitHeight: 120 * Style.uiScaleRatio

      Item {
        id: graphArea
        anchors.fill: parent

        NGraph {
          id: graph
          anchors.fill: parent
          values: graphRoot.history
          minValue: 0
          maxValue: graphRoot.maxValue
          color: graphRoot.accentColor
          strokeWidth: Math.max(1, Style.uiScaleRatio)
          fill: true
          fillOpacity: 0.15
          updateInterval: SystemStatService.networkIntervalMs
          animateScale: true
        }

        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true

          readonly property int idx: {
            const n = graphRoot.history.length;
            if (n < 2 || !containsMouse)
              return -1;
            return Math.max(0, Math.min(n - 1, Math.round(mouseX / width * (n - 1))));
          }

          readonly property real value: idx >= 0 ? (graphRoot.history[idx] ?? -1) : -1

          Rectangle {
            visible: hover.idx >= 0
            x: {
              const n = graphRoot.history.length;
              if (hover.idx < 0 || n < 2)
                return 0;
              return (hover.idx / (n - 1)) * parent.width - width / 2;
            }
            width: 1
            height: parent.height
            color: Qt.alpha(Color.mOnSurface, 0.25)

            Rectangle {
              readonly property string _label: {
                if (hover.value < 0)
                  return "";
                return graphRoot.formatSpeed(hover.value);
              }

              readonly property real posX: -implicitWidth / 2
              x: Math.max(-parent.x, Math.min(graphArea.width - parent.x - implicitWidth, posX))
              y: Style.marginXS

              implicitWidth: bubbleText.implicitWidth + Style.marginS * 2
              implicitHeight: bubbleText.implicitHeight + Style.marginXS * 2
              radius: Style.radiusS
              color: Color.mSurfaceVariant
              border.color: Qt.alpha(Color.mOnSurface, 0.15)
              border.width: 1

              NText {
                id: bubbleText
                anchors.centerIn: parent
                text: parent._label
                pointSize: Style.fontSizeXS
                color: Color.mOnSurface
              }
            }
          }
        }
      }
    }
  }
}

import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property string iconKey: cfg.icon ?? defaults.icon ?? "adjustments-horizontal"
  readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "primary"
  
  icon: iconKey
  tooltipText: pluginApi?.tr("widget.tooltip")
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  customRadius: Style.radiusM 

  colorBg: Style.capsuleColor
  
  colorFg: {
    let resolved = Color.resolveColorKeyOptional(iconColorKey);
    if (root.containsMouse) return Color.mOnHover;
    return resolved.a > 0 ? resolved : Color.mOnSurface;
  }

  border.color: Style.capsuleBorderColor
  border.width: Style.borderS

  Behavior on colorFg {
    ColorAnimation { 
      duration: Style.animationFast
      easing.type: Easing.InOutQuad 
    }
  }

  onClicked: {
    if (pluginApi) {
      pluginApi.openPanel(root.screen, this);
    }
  }

  onEntered: {
    TooltipService.show(root, pluginApi?.tr("widget.tooltip"), BarService.getTooltipDirection(screen?.name))
  }
  
  onExited: {
    TooltipService.hide()
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": pluginApi?.tr("widget.menu_settings"),
        "action": "settings",
        "icon": "settings"
      },
    ]

    onTriggered: function (action) {
      contextMenu.close();
      PanelService.closeContextMenu(screen);
      if (action === "settings") {
        BarService.openPluginSettings(root.screen, pluginApi.manifest);
      }
    }
  }

  onRightClicked: {
    PanelService.showContextMenu(contextMenu, root, screen);
  }
}
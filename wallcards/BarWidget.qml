import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "none"
  property var pluginApi: null
  property ShellScreen screen
  property string section: ""
  property string widgetId: ""

  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth
  colorBg: Style.capsuleColor
  colorFg: Color.resolveColorKey(iconColorKey)
  customRadius: Style.radiusL
  icon: "cards"
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  tooltipText: pluginApi?.tr("widget.tooltip")

  onClicked: {
    if (pluginApi) {
      root.pluginApi?.mainInstance.toggle();
    }
  }
}

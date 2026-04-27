import QtQuick
import Quickshell
import qs.Widgets

NIconButtonHot {
    property ShellScreen screen
    property var pluginApi: null

    icon: "screen-share"
    tooltipText: pluginApi?.tr("bar.tooltip.inactive")
    onClicked: {
        if (pluginApi) pluginApi.togglePanel(screen, this);
    }
}

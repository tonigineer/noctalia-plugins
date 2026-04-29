import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null

    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string valueColor: cfg.color ?? defaults.color ?? "#0064ff"
    property bool valueColorIcon: cfg.colorIcon ?? defaults.colorIcon ?? false
    property bool valueHideOnEmpty: cfg.hideOnEmpty ?? defaults.hideOnEmpty ?? false

    spacing: Style.marginL

    NText {
        text: pluginApi?.tr("settings.lightbar_color")
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NColorPicker {
        Layout.fillWidth: true
        selectedColor: root.valueColor
        onColorSelected: color => root.valueColor = color
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        text: pluginApi?.tr("settings.widget_settings")
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.color_icon.label")
        description: pluginApi?.tr("settings.color_icon.desc")
        checked: root.valueColorIcon
        onToggled: checked => root.valueColorIcon = checked
    }

    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.hide_empty.label")
        description: pluginApi?.tr("settings.hide_empty.desc")
        checked: root.valueHideOnEmpty
        onToggled: checked => root.valueHideOnEmpty = checked
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        text: pluginApi?.tr("settings.info")
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NBox {
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginS

            NText {
                text: pluginApi?.tr("settings.info_desc1")
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            NText {
                text: pluginApi?.tr("settings.info_desc2")
                pointSize: Style.fontSizeS
                color: Color.mSecondary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    // Called by the shell when the user clicks "Save"
    function saveSettings() {
        if (!pluginApi) return

        pluginApi.pluginSettings.color = root.valueColor
        pluginApi.pluginSettings.colorIcon = root.valueColorIcon
        pluginApi.pluginSettings.hideOnEmpty = root.valueHideOnEmpty
        pluginApi.saveSettings()

        if (pluginApi.mainInstance) {
            pluginApi.mainInstance.applyColors()
        }
    }
}

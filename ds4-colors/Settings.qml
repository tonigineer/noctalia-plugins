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
        text: "Lightbar Color"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NTextInput {
        Layout.fillWidth: true
        label: "Hex Color"
        description: "Enter color code (e.g., #ff0000)"
        text: root.valueColor
        onTextChanged: root.valueColor = text
    }

    Rectangle {
        Layout.preferredWidth: 64
        Layout.preferredHeight: 64
        radius: Style.radiusM
        color: {
            const c = Qt.color(root.valueColor)
            return isNaN(c.r) ? "transparent" : c
        }
        border.color: Color.mOutline
        border.width: 1
    }

    NText {
        text: "Presets"
        pointSize: Style.fontSizeS
        font.weight: Font.Bold
        color: Color.mOnSurface
        Layout.topMargin: Style.marginS
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 8
        rowSpacing: Style.marginS
        columnSpacing: Style.marginS

        Repeater {
            model: [
                "#ff0000", "#ff7f00", "#ffff00", "#7fff00",
                "#00ff00", "#00ff7f", "#00ffff", "#007fff",
                "#0000ff", "#7f00ff", "#ff00ff", "#ff007f",
                "#ffffff", "#ff88aa", "#0064ff", "#000000"
            ]
            delegate: Rectangle {
                required property string modelData
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Style.radiusS
                color: modelData
                border.color: Color.mOutline
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.valueColor = modelData
                        root.applyAndSave()
                    }
                }
            }
        }
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        text: "Widget Settings"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: "Color Widget Icon"
        description: "Use the lightbar color for the bar widget icon"
        checked: root.valueColorIcon
        onToggled: checked => root.valueColorIcon = checked
    }

    NToggle {
        Layout.fillWidth: true
        label: "Hide When Disconnected"
        description: "Hide the bar widget if no controllers are detected"
        checked: root.valueHideOnEmpty
        onToggled: checked => root.valueHideOnEmpty = checked
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        text: "Info"
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
                text: "This plugin controls DS4/DualSense LED colors via sysfs."
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            NText {
                text: "If colors don't apply, run: sudo ./setup_rules.sh"
                pointSize: Style.fontSizeS
                color: Color.mSecondary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    // Persist settings and immediately apply color to the controller
    function applyAndSave() {
        if (!pluginApi) return

        pluginApi.pluginSettings.color = root.valueColor
        pluginApi.pluginSettings.colorIcon = root.valueColorIcon
        pluginApi.pluginSettings.hideOnEmpty = root.valueHideOnEmpty
        pluginApi.saveSettings()

        if (pluginApi.mainInstance) {
            pluginApi.mainInstance.applyColors()
        }
    }

    // Called by the shell when the user clicks "Save"
    function saveSettings() {
        applyAndSave()
    }
}

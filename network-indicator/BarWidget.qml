import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var pluginApi: null

    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // ── Configuration ──

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string arrowType: cfg.arrowType ?? defaults.arrowType
    property int minWidth: cfg.minWidth ?? defaults.minWidth

    property bool useCustomColors: cfg.useCustomColors ?? defaults.useCustomColors
    property bool showNumbers: cfg.showNumbers ?? defaults.showNumbers
    property bool forceMegabytes: cfg.forceMegabytes ?? defaults.forceMegabytes

    property color colorSilent: root.useCustomColors && cfg.colorSilent || Color.mSurfaceVariant
    property color colorTx: root.useCustomColors && cfg.colorTx || Color.mSecondary
    property color colorRx: root.useCustomColors && cfg.colorRx || Color.mPrimary
    property color colorText: root.useCustomColors && cfg.colorText || Color.mOnSurfaceVariant

    property int byteThresholdActive: cfg.byteThresholdActive ?? defaults.byteThresholdActive
    property real fontSizeModifier: cfg.fontSizeModifier ?? defaults.fontSizeModifier
    property real iconSizeModifier: cfg.iconSizeModifier ?? defaults.iconSizeModifier
    property real spacingInbetween: cfg.spacingInbetween ?? defaults.spacingInbetween
    property real contentMargin: cfg.contentMargin ?? defaults.contentMargin ?? Style.marginS

    property bool useCustomFont: cfg.useCustomFont ?? defaults.useCustomFont
    property string customFontFamily: cfg.customFontFamily ?? defaults.customFontFamily
    property bool customFontBold: cfg.customFontBold ?? defaults.customFontBold
    property bool customFontItalic: cfg.customFontItalic ?? defaults.customFontItalic

    property bool horizontalNumbers: cfg.horizontalLayout ?? defaults.horizontalLayout

    readonly property string resolvedFontFamily: {
        if (root.useCustomFont && root.customFontFamily)
            return root.customFontFamily;
        return Settings.data.ui.fontDefault;
    }

    readonly property int resolvedFontWeight: {
        if (root.useCustomFont && root.customFontBold)
            return Font.Bold;
        return Style.fontWeightMedium;
    }

    readonly property bool resolvedFontItalic: root.useCustomFont && root.customFontItalic

    readonly property bool numbersVisible: root.showNumbers && barIsSpacious && !barIsVertical

    property string barPosition: Settings.data.bar.position || "top"
    property string barDensity: Settings.data.bar.density || "compact"
    property bool barIsSpacious: barDensity != "mini"
    property bool barIsVertical: barPosition === "left" || barPosition === "right"

    readonly property real naturalWidth: contentRow.implicitWidth + root.contentMargin * 2
    readonly property real contentWidth: barIsVertical ? Style.capsuleHeight : Math.max(naturalWidth, minWidth)
    readonly property real contentHeight: barIsVertical ? Math.round(contentRow.implicitHeight + Style.marginM * 2) : Style.capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // ── Widget ──

    property real txSpeed: SystemStatService.txSpeed
    property real rxSpeed: SystemStatService.rxSpeed

    readonly property real maxTextWidth: Math.max(txTextMetrics.width, rxTextMetrics.width)

    TextMetrics {
        id: txTextMetrics
        text: convertBytes(root.txSpeed)
        font.family: root.resolvedFontFamily
        font.weight: root.resolvedFontWeight
        font.italic: root.resolvedFontItalic
        font.pointSize: Style.barFontSize * root.fontSizeModifier
    }

    TextMetrics {
        id: rxTextMetrics
        text: convertBytes(root.rxSpeed)
        font.family: root.resolvedFontFamily
        font.weight: root.resolvedFontWeight
        font.italic: root.resolvedFontItalic
        font.pointSize: Style.barFontSize * root.fontSizeModifier
    }

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: root.useCustomColors && cfg.colorBackground || Style.capsuleColor
        radius: Style.radiusM
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.marginS

            // Vertical layout: stacked values to the left
            Column {
                visible: root.numbersVisible && !root.horizontalNumbers
                spacing: root.spacingInbetween

                NText {
                    width: root.maxTextWidth
                    horizontalAlignment: Text.AlignRight
                    text: convertBytes(root.txSpeed)
                    color: root.colorText
                    pointSize: Style.barFontSize * root.fontSizeModifier
                    font.family: root.resolvedFontFamily
                    font.weight: root.resolvedFontWeight
                    font.italic: root.resolvedFontItalic
                }

                NText {
                    width: root.maxTextWidth
                    horizontalAlignment: Text.AlignRight
                    text: convertBytes(root.rxSpeed)
                    color: root.colorText
                    pointSize: Style.barFontSize * root.fontSizeModifier
                    font.family: root.resolvedFontFamily
                    font.weight: root.resolvedFontWeight
                    font.italic: root.resolvedFontItalic
                }
            }

            // Horizontal layout: TX value left
            NText {
                visible: root.numbersVisible && root.horizontalNumbers
                Layout.preferredWidth: root.maxTextWidth
                horizontalAlignment: Text.AlignRight
                text: convertBytes(root.txSpeed)
                color: root.colorText
                pointSize: Style.barFontSize * root.fontSizeModifier
                font.family: root.resolvedFontFamily
                font.weight: root.resolvedFontWeight
                font.italic: root.resolvedFontItalic
            }

            // Icons
            Column {
                spacing: -10.0 + root.spacingInbetween

                NIcon {
                    icon: arrowType + "-up"
                    color: root.txSpeed >= root.byteThresholdActive ? root.colorTx : root.colorSilent
                    pointSize: Style.fontSizeL * root.iconSizeModifier
                }

                NIcon {
                    icon: arrowType + "-down"
                    color: root.rxSpeed >= root.byteThresholdActive ? root.colorRx : root.colorSilent
                    pointSize: Style.fontSizeL * root.iconSizeModifier
                }
            }

            // Horizontal layout: RX value right
            NText {
                visible: root.numbersVisible && root.horizontalNumbers
                Layout.preferredWidth: root.maxTextWidth
                horizontalAlignment: Text.AlignLeft
                text: convertBytes(root.rxSpeed)
                color: root.colorText
                pointSize: Style.barFontSize * root.fontSizeModifier
                font.family: root.resolvedFontFamily
                font.weight: root.resolvedFontWeight
                font.italic: root.resolvedFontItalic
            }
        }
    }

    // ── Interaction ──

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onPressed: mouse => {
            if (mouse.button == Qt.RightButton)
                PanelService.showContextMenu(contextMenu, root, screen);
        }

        NPopupContextMenu {
            id: contextMenu

            model: [
                {
                    "label": I18n.tr("actions.widget-settings"),
                    "action": "widget-settings",
                    "icon": "settings"
                },
            ]

            onTriggered: action => {
                contextMenu.close();
                PanelService.closeContextMenu(screen);

                if (action === "widget-settings") {
                    BarService.openPluginSettings(screen, pluginApi.manifest);
                }
            }
        }
    }

    // ── Utilities ──

    function convertBytes(bytesPerSecond) {
        const KB = 1024;
        const MB = KB * 1024;

        if (bytesPerSecond < MB && !root.forceMegabytes)
            return (bytesPerSecond / KB).toFixed(1) + " KB";

        return (bytesPerSecond / MB).toFixed(1) + " MB";
    }
}

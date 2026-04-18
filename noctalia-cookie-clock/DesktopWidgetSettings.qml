import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginM

    // Plugin API (injected by the settings dialog system)
    property var pluginApi: null

    // Widget settings object (injected by the settings dialog system)
    property var widgetSettings: null

    // Local state - initialize from widgetSettings.data with metadata fallback
    property int valueSides: widgetSettings?.data?.sides ?? pluginApi?.manifest?.metadata?.defaultSettings?.sides ?? 9
    property string valueDialStyle: widgetSettings?.data?.dialStyle ?? pluginApi?.manifest?.metadata?.defaultSettings?.dialStyle ?? "dots"
    property string valueHourHandStyle: widgetSettings?.data?.hourHandStyle ?? pluginApi?.manifest?.metadata?.defaultSettings?.hourHandStyle ?? "fill"
    property string valueMinuteHandStyle: widgetSettings?.data?.minuteHandStyle ?? pluginApi?.manifest?.metadata?.defaultSettings?.minuteHandStyle ?? "medium"
    property string valueSecondHandStyle: widgetSettings?.data?.secondHandStyle ?? pluginApi?.manifest?.metadata?.defaultSettings?.secondHandStyle ?? "dot"
    property string valueDateStyle: widgetSettings?.data?.dateStyle ?? pluginApi?.manifest?.metadata?.defaultSettings?.dateStyle ?? "bubble"
    property bool valueShowSeconds: widgetSettings?.data?.showSeconds ?? pluginApi?.manifest?.metadata?.defaultSettings?.showSeconds ?? true
    property bool valueShowHourMarks: widgetSettings?.data?.showHourMarks ?? pluginApi?.manifest?.metadata?.defaultSettings?.showHourMarks ?? false
    property real valueBackgroundOpacity: widgetSettings?.data?.backgroundOpacity ?? pluginApi?.manifest?.metadata?.defaultSettings?.backgroundOpacity ?? 1.0

    NComboBox {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.dial-style-label") ?? "Dial Marks Style"
        description: root.pluginApi?.tr("desktopWidgetSettings.dial-style-description") ?? "Style of the hour and minute markers"
        model: [
            { "key": "dots", "name": root.pluginApi?.tr("desktopWidgetSettings.style-dots") ?? "Dots" },
            { "key": "numbers", "name": root.pluginApi?.tr("desktopWidgetSettings.style-numbers") ?? "Numbers" },
            { "key": "full", "name": root.pluginApi?.tr("desktopWidgetSettings.style-full") ?? "Full lines" },
            { "key": "none", "name": root.pluginApi?.tr("desktopWidgetSettings.style-none") ?? "None" }
        ]
        currentKey: root.valueDialStyle
        onSelected: key => {
            root.valueDialStyle = key;
            saveSettings();
        }
    }

    NComboBox {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.hour-hand-label") ?? "Hour Hand Style"
        description: root.pluginApi?.tr("desktopWidgetSettings.hour-hand-description") ?? "Visual style of the hour hand"
        model: [
            { "key": "fill", "name": root.pluginApi?.tr("desktopWidgetSettings.style-fill") ?? "Fill" },
            { "key": "hollow", "name": root.pluginApi?.tr("desktopWidgetSettings.style-hollow") ?? "Hollow" },
            { "key": "classic", "name": root.pluginApi?.tr("desktopWidgetSettings.style-classic") ?? "Classic" },
            { "key": "hide", "name": root.pluginApi?.tr("desktopWidgetSettings.style-hide") ?? "Hide" }
        ]
        currentKey: root.valueHourHandStyle
        onSelected: key => {
            root.valueHourHandStyle = key;
            saveSettings();
        }
    }

    NComboBox {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.minute-hand-label") ?? "Minute Hand Style"
        description: root.pluginApi?.tr("desktopWidgetSettings.minute-hand-description") ?? "Visual style of the minute hand"
        model: [
            { "key": "bold", "name": root.pluginApi?.tr("desktopWidgetSettings.style-bold") ?? "Bold" },
            { "key": "medium", "name": root.pluginApi?.tr("desktopWidgetSettings.style-medium") ?? "Medium" },
            { "key": "thin", "name": root.pluginApi?.tr("desktopWidgetSettings.style-thin") ?? "Thin" },
            { "key": "classic", "name": root.pluginApi?.tr("desktopWidgetSettings.style-classic") ?? "Classic" },
            { "key": "hide", "name": root.pluginApi?.tr("desktopWidgetSettings.style-hide") ?? "Hide" }
        ]
        currentKey: root.valueMinuteHandStyle
        onSelected: key => {
            root.valueMinuteHandStyle = key;
            saveSettings();
        }
    }
    
    NComboBox {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.second-hand-label") ?? "Second Hand Style"
        description: root.pluginApi?.tr("desktopWidgetSettings.second-hand-description") ?? "Visual style of the second hand"
        model: [
            { "key": "dot", "name": root.pluginApi?.tr("desktopWidgetSettings.style-dot") ?? "Dot" },
            { "key": "classic", "name": root.pluginApi?.tr("desktopWidgetSettings.style-classic") ?? "Classic" },
            { "key": "line", "name": root.pluginApi?.tr("desktopWidgetSettings.style-line") ?? "Line" },
            { "key": "hide", "name": root.pluginApi?.tr("desktopWidgetSettings.style-hide") ?? "Hide" }
        ]
        currentKey: root.valueSecondHandStyle
        onSelected: key => {
            root.valueSecondHandStyle = key;
            saveSettings();
        }
    }

    NComboBox {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.date-style-label") ?? "Date Style"
        description: root.pluginApi?.tr("desktopWidgetSettings.date-style-description") ?? "How to display the current date"
        model: [
            { "key": "bubble", "name": root.pluginApi?.tr("desktopWidgetSettings.style-bubble") ?? "Bubbles" },
            { "key": "hide", "name": root.pluginApi?.tr("desktopWidgetSettings.style-hide") ?? "Hide" }
        ]
        currentKey: root.valueDateStyle
        onSelected: key => {
            root.valueDateStyle = key;
            saveSettings();
        }
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    NToggle {
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.show-hour-marks-label") ?? "Show Inner Hour Marks"
        description: root.pluginApi?.tr("desktopWidgetSettings.show-hour-marks-description") ?? "Display an inner set of hour markings"
        checked: root.valueShowHourMarks
        onToggled: checked => {
            root.valueShowHourMarks = checked;
            saveSettings();
        }
        defaultValue: false
    }

    NValueSlider {
        property real _value: root.valueBackgroundOpacity * 100
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.background-opacity-label") ?? "Background Opacity"
        description: root.pluginApi?.tr("desktopWidgetSettings.background-opacity-description") ?? "Adjust the transparency of the cookie shape"
        value: _value
        text: Math.round(_value) + "%"
        from: 0
        to: 100
        stepSize: 1
        defaultValue: 100
        onMoved: value => _value = value
        onPressedChanged: (pressed, value) => {
            if (!pressed) { 
                root.valueBackgroundOpacity = value / 100; 
                root.saveSettings(); 
            }
        }
    }

    NValueSlider {
        property int _value: root.valueSides
        Layout.fillWidth: true
        label: root.pluginApi?.tr("desktopWidgetSettings.cookie-shape-label") ?? "Cookie Shape Corners"
        description: root.pluginApi?.tr("desktopWidgetSettings.cookie-shape-description") ?? "Number of sine wave edges"
        value: _value
        text: String(_value)
        from: 3
        to: 20
        stepSize: 1
        defaultValue: 9
        onMoved: value => _value = Math.round(value)
        onPressedChanged: (pressed, value) => {
            if (!pressed) { 
                root.valueSides = Math.round(value); 
                root.saveSettings(); 
            }
        }
    }

    function saveSettings() {
        if (!widgetSettings) return;
        
        // Use object assignment to ensure data is created properly if null
        var data = widgetSettings.data || {};
        
        data.sides = root.valueSides;
        data.dialStyle = root.valueDialStyle;
        data.hourHandStyle = root.valueHourHandStyle;
        data.minuteHandStyle = root.valueMinuteHandStyle;
        data.secondHandStyle = root.valueSecondHandStyle;
        data.dateStyle = root.valueDateStyle;
        data.showSeconds = root.valueShowSeconds;
        data.showHourMarks = root.valueShowHourMarks;
        data.backgroundOpacity = root.valueBackgroundOpacity;
        
        widgetSettings.data = data;
        widgetSettings.save();
    }
}

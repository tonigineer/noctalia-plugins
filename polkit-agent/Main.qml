import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import qs.Commons

Item {
    id: root
    property var pluginApi: null

    PolkitAgent {
        id: agent
        
        onIsActiveChanged: {
            if (isActive) {
                openWindow()
            } else {
                closeWindow()
            }
        }
    }

    property var window: null

    function openWindow() {
        if (window === null) {
            window = Qt.createComponent("PolkitWindow.qml").createObject(root, {
                flow: agent.flow,
                pluginApi: Qt.binding(function() { return root.pluginApi })
            });
            window.visible = true;
        } else {
            window.flow = agent.flow
            window.pluginApi = root.pluginApi
            window.visible = true
        }
    }

    function closeWindow() {
        if (window !== null) {
            window.destroy();
            window = null;
        }
    }
}

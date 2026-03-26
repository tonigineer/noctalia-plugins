import QtQuick
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null

  function hide() {
    windowLoader.active = false;
  }
  function show() {
    windowLoader.active = true;
  }
  function toggle() {
    windowLoader.active = !windowLoader.active;
  }

  Loader {
    id: windowLoader

    active: false
    source: "Wallcards.qml"

    onLoaded: item.pluginApi = Qt.binding(() => root.pluginApi)

    Connections {
      function onQuitRequested() {
        root.hide();
      }
      function onShowRequested() {
        root.show();
      }

      target: windowLoader.item
    }
  }
  IpcHandler {
    function hide() {
      root.hide();
    }
    function show() {
      root.show();
    }
    function toggle() {
      root.toggle();
    }

    target: "plugin:wallcards"
  }
}

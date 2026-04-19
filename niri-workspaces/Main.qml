import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Compositor
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null

  readonly property bool isNiri: CompositorService.isNiri

  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  readonly property string launcherPrefix: cfg.launcherPrefix ?? defaults.launcherPrefix ?? ">ws"

  property var workspaces: []
  readonly property var focusedWorkspace: {
    for (var i = 0; i < workspaces.length; i++) {
      if (workspaces[i].is_focused) return workspaces[i];
    }
    return null;
  }

  // Workspaces sorted by output then visual index (idx). Recomputed whenever
  // `workspaces` changes so LauncherProvider bindings stay live.
  readonly property var sortedWorkspaces: {
    var copy = workspaces.slice();
    copy.sort(function (a, b) {
      var ao = a.output || "";
      var bo = b.output || "";
      if (ao !== bo) return ao < bo ? -1 : 1;
      return (a.idx || 0) - (b.idx || 0);
    });
    return copy;
  }

  // Resolve a workspace into a `--workspace` reference acceptable to the
  // niri CLI. The CLI parses numeric refs as *idx* (not id) via
  // WorkspaceReferenceArg::Index, so `ws.idx` is the only correct numeric
  // reference — `ws.id` would silently target a different workspace.
  // Names are unique across niri and preferred when available.
  function workspaceRef(ws) {
    if (!ws) return null;
    if (ws.name && ws.name.length > 0) return ws.name;
    return String(ws.idx);
  }

  function findWorkspaceById(id) {
    for (var i = 0; i < workspaces.length; i++) {
      if (workspaces[i].id === id) return workspaces[i];
    }
    return null;
  }

  function renameWorkspace(ws, newName) {
    if (!isNiri || !ws) return;
    var trimmed = (newName || "").trim();
    // niri's two subcommands take the target in different forms:
    //   set-workspace-name <NAME> [--workspace <REF>]
    //   unset-workspace-name [<REF>]
    // Passing --workspace to unset-workspace-name makes niri reject the
    // command, so branch here. Omitting the reference entirely makes niri
    // target the focused workspace, which is what we want when ws is
    // already focused (also avoids our idx ref misfiring for unnamed
    // workspaces).
    var args = ["niri", "msg", "action"];
    var ref = ws.is_focused ? null : workspaceRef(ws);

    if (trimmed.length === 0) {
      args.push("unset-workspace-name");
      if (ref !== null) args.push(ref);
    } else {
      args.push("set-workspace-name", trimmed);
      if (ref !== null) args.push("--workspace", ref);
    }

    Logger.i("NiriWorkspaces", "Running:", args.join(" "));
    Quickshell.execDetached(args);
  }

  function unsetWorkspaceName(ws) {
    renameWorkspace(ws, "");
  }

  function renameCurrent(newName) {
    if (!focusedWorkspace) {
      Logger.w("NiriWorkspaces", "No focused workspace to rename");
      return;
    }
    renameWorkspace(focusedWorkspace, newName);
  }

  function unsetCurrentName() {
    if (!focusedWorkspace) {
      Logger.w("NiriWorkspaces", "No focused workspace to unset");
      return;
    }
    unsetWorkspaceName(focusedWorkspace);
  }

  function focusWorkspace(ws) {
    if (!isNiri || !ws) return;
    // niri's `focus-workspace <idx>` toggles back to the previous workspace
    // when the target is already focused. Skip the dispatch so re-selecting
    // the current workspace is a no-op.
    if (ws.is_focused) return;
    var ref = workspaceRef(ws);
    if (ref === null) return;
    Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", ref]);
  }

  // --- Niri event stream ---
  // niri prints one JSON object per line. On connect it emits a snapshot
  // (WorkspacesChanged + friends) followed by incremental events.
  Process {
    id: eventStream
    command: ["niri", "msg", "--json", "event-stream"]
    running: false

    stdout: SplitParser {
      onRead: line => root.handleEventLine(line)
    }

    onExited: function (exitCode) {
      Logger.w("NiriWorkspaces", "event-stream exited with code", exitCode);
      if (root.isNiri) restartTimer.start();
    }
  }

  Timer {
    id: restartTimer
    interval: 2000
    repeat: false
    onTriggered: {
      if (root.isNiri && !eventStream.running) {
        eventStream.running = true;
      }
    }
  }

  function handleEventLine(line) {
    if (!line || line.length === 0) return;
    var evt;
    try {
      evt = JSON.parse(line);
    } catch (e) {
      return;
    }

    if (evt.WorkspacesChanged && Array.isArray(evt.WorkspacesChanged.workspaces)) {
      root.workspaces = evt.WorkspacesChanged.workspaces;
      return;
    }

    if (evt.WorkspaceActivated) {
      var activated = evt.WorkspaceActivated;
      var targetOutput = null;
      for (var j = 0; j < root.workspaces.length; j++) {
        if (root.workspaces[j].id === activated.id) {
          targetOutput = root.workspaces[j].output;
          break;
        }
      }
      var copy = [];
      for (var i = 0; i < root.workspaces.length; i++) {
        var ws = root.workspaces[i];
        var updated = Object.assign({}, ws);
        if (ws.id === activated.id) {
          updated.is_active = true;
          if (activated.focused) updated.is_focused = true;
        } else {
          // Exactly one active workspace per output.
          if (targetOutput !== null && ws.output === targetOutput) {
            updated.is_active = false;
          }
          // Exactly one focused workspace globally.
          if (activated.focused) updated.is_focused = false;
        }
        copy.push(updated);
      }
      root.workspaces = copy;
      return;
    }

    // Other events (WindowsChanged, KeyboardLayoutsChanged, etc) are ignored.
  }

  IpcHandler {
    target: "plugin:niri-workspaces"

    // Mirrors the shell's `launcher emoji` toggle: open the launcher in
    // workspace mode, close it if already in that mode, or switch modes if
    // it's open on a different prefix.
    function toggle() {
      if (!pluginApi) return;
      pluginApi.withCurrentScreen(screen => {
        var prefix = root.launcherPrefix;
        var searchText = PanelService.getLauncherSearchText(screen);
        var isInWsMode = searchText.startsWith(prefix);
        if (!PanelService.isLauncherOpen(screen)) {
          PanelService.openLauncherWithSearch(screen, prefix + " ");
        } else if (isInWsMode) {
          PanelService.closeLauncher(screen);
        } else {
          PanelService.setLauncherSearchText(screen, prefix + " ");
        }
      }, Settings.data.appLauncher.overviewLayer);
    }

    function renameCurrent(name: string) {
      root.renameCurrent(name);
    }

    function unsetCurrent() {
      root.unsetCurrentName();
    }
  }

  Component.onCompleted: {
    if (isNiri) {
      eventStream.running = true;
      Logger.i("NiriWorkspaces", "Listening to niri event-stream");
    } else {
      Logger.w("NiriWorkspaces", "Not running on Niri — plugin inactive");
    }
  }

  Component.onDestruction: {
    eventStream.running = false;
  }
}

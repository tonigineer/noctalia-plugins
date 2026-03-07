import QtQuick
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null
  property bool mirroringActive: mirrorProcess.running
  property string sourceOutput: ""
  property string destinationOutput: ""
  property string lastError: ""
  property bool stopRequested: false
  property bool suppressNextStderr: false

  function isIgnorableWlMirrorLine(line) {
    const normalized = String(line || "").trim().toLowerCase();
    if (normalized.length === 0) {
      return true;
    }

    return normalized.indexOf("mirror-extcopy::init(): missing ext_image_copy_capture protocol") !== -1
      || normalized.indexOf("mirror::auto_backend_fallback():") !== -1;
  }

  function isBackendAttemptFailureLine(line) {
    const normalized = String(line || "").trim().toLowerCase();
    if (normalized.length === 0) {
      return false;
    }

    return normalized.indexOf("failed") !== -1 && normalized.indexOf("backend") !== -1
      || normalized.indexOf("missing") !== -1 && normalized.indexOf("protocol") !== -1
      || normalized.indexOf("no supported") !== -1 && normalized.indexOf("backend") !== -1;
  }

  function startMirror(source, destination) {
    if (mirrorProcess.running) {
      root.lastError = root.pluginApi?.tr("main.error.alreadyMirroring") || "A mirror session is already active. Stop it before starting another.";
      return;
    }

    if (!source || !destination) {
      root.lastError = root.pluginApi?.tr("main.error.selectBothMonitors") || "Please select both source and destination monitors.";
      return;
    }

    if (source === destination) {
      root.lastError = root.pluginApi?.tr("main.error.sameMonitor") || "Source and destination must be different monitors.";
      return;
    }

    root.lastError = "";

    root.sourceOutput = source;
    root.destinationOutput = destination;

    mirrorProcess.command = [
      "wl-mirror",
      "--fullscreen-output",
      destination,
      source
    ];
    root.stopRequested = false;
    mirrorProcess.running = true;
  }

  function stopMirror() {
    if (mirrorProcess.running) {
      root.stopRequested = true;
      root.suppressNextStderr = true;
      mirrorProcess.signal(15);
    }
  }

  Process {
    id: mirrorProcess
    running: false
    command: []

    onExited: (exitCode, exitStatus) => {
      if (root.stopRequested) {
        root.stopRequested = false;
        return;
      }

      if (exitCode !== 0 && exitStatus !== Process.NormalExit) {
        root.lastError = root.pluginApi?.tr("main.error.unexpectedExit") || "wl-mirror exited unexpectedly.";
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (root.suppressNextStderr) {
          root.suppressNextStderr = false;
          return;
        }

        const lines = text.split("\n");
        const remaining = [];
        let sawBackendAttemptFailure = false;

        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (line.length === 0 || root.isIgnorableWlMirrorLine(line)) {
            continue;
          }

          if (root.isBackendAttemptFailureLine(line)) {
            sawBackendAttemptFailure = true;
            continue;
          }

          remaining.push(line);
        }

        const msg = remaining.join("\n").trim();
        if (msg.length > 0) {
          root.lastError = msg;
        } else if (sawBackendAttemptFailure) {
          root.lastError = root.pluginApi?.tr("main.error.noCompatibleBackend") || "wl-mirror could not start: no compatible backend worked.";
        }
      }
    }
  }

}

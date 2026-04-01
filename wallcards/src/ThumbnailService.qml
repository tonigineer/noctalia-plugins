import "Utils.js" as Utils
import QtQuick
import Quickshell.Io
import Qt.labs.folderlistmodel

Item {
  id: service

  required property string cacheDir
  property int fileCount: files.length
  property var files: []
  required property var filterImages
  required property var filterVideos
  property bool loading: true
  property int pendingProcesses: 0
  property int thumbnailRevision: 0
  required property string wallpaperDir

  signal ready

  function buildFileList() {
    var items = [];
    for (var i = 0; i < folderModel.count; i++) {
      var fileName = folderModel.get(i, "fileName");
      var isVideo = Utils.isVideo(fileName, service.filterVideos);
      items.push({
        fileName: fileName,
        filePath: folderModel.get(i, "filePath"),
        thumbnail: cacheDir + "/" + Utils.thumbnailName(fileName, service.filterVideos),
        isVideo: isVideo
      });
    }
    files = items;
  }
  function createThumbnails() {
    var proc = processComponent.createObject(null, {
      command: ["mkdir", "-p", cacheDir]
    });
    proc.running = true;

    for (var i = 0; i < folderModel.count; i++) {
      (function (idx) {
          var filePath = folderModel.get(idx, "filePath");
          var fileName = folderModel.get(idx, "fileName");
          var thumbName = Utils.thumbnailName(fileName, service.filterVideos);
          var thumbnail = cacheDir + "/" + thumbName;

          var cmd = Utils.isVideo(fileName, service.filterVideos) ? videoCommand(filePath, thumbnail) : imageCommand(filePath, thumbnail);

          service.pendingProcesses++;
          var proc = processComponent.createObject(null, {
            command: ["bash", "-c", cmd]
          });

          proc.exited.connect(function () {
            service.pendingProcesses--;
            service.thumbnailRevision++;

            if (service.pendingProcesses === 0) {
              service.loading = false;
              service.ready();
            }

            proc.destroy();
          });

          proc.running = true;
        })(i);
    }

    if (folderModel.count === 0) {
      service.loading = false;
      service.ready();
    }
  }
  function imageCommand(filePath, thumbnail) {
    return "[ -f '" + thumbnail + "' ] || magick '" + filePath + "' -resize x500 -quality 95" + " '" + thumbnail + "'";
  }
  function videoCommand(filePath, thumbnail) {
    return "[ -f '" + thumbnail + "' ] || ffmpeg -y -i '" + filePath + "' -vf 'select=eq(n\\,0),scale=-1:1080'" + " -frames:v 1 -q:v 2" + " '" + thumbnail + "' </dev/null 2>/dev/null";
  }

  FolderListModel {
    id: folderModel

    folder: service.wallpaperDir ? Qt.resolvedUrl("file://" + service.wallpaperDir) : ""
    nameFilters: Utils.nameFilters(service.filterImages, service.filterVideos)
    showDirs: false
    sortField: FolderListModel.Name

    onStatusChanged: {
      if (status === FolderListModel.Ready) {
        service.buildFileList();
        service.createThumbnails();
      }
    }
  }
  Component {
    id: processComponent

    Process {
    }
  }
}

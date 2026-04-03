import "Utils.js" as Utils
import QtQuick
import Quickshell.Io
import Qt.labs.folderlistmodel

Item {
  id: service

  required property string cacheDir
  required property var filterImages
  required property var filterVideos
  required property string wallpaperDir
  
  property int fileCount: files.length
  property var files: []
  property bool loading: true
  property int pendingProcesses: 0
  property int thumbnailRevision: 0

  signal ready

  function buildFileList() {
    var items = [];

    for (let i = 0; i < folderModel2.count; i++) {
      let filePath = folderModel2.get(i, "filePath");
      let fileName = folderModel2.get(i, "fileName").substring(0, filePath.lastIndexOf("_x"));

      let idx = fileName.lastIndexOf("__x");
      let wallpaperName = fileName.substring(0, idx);
      let hexColor = fileName.substring(idx + 2);
      var isVideo = Utils.isVideo(wallpaperName, service.filterVideos);

      console.log(wallpaperName);
      items.push({
        fileName: wallpaperName,
        filePath: wallpaperDir + "/" + wallpaperName,
        thumbnail: filePath,
        colorCode: hexColor,
        isVideo: isVideo
      });
    }

    files = items;
    service.loading = false;
    service.ready();
  }

  function createThumbnails() {
    var proc = processComponent.createObject(null, {
      command: ["mkdir", "-p", cacheDir]
    });
    proc.running = true;

    var items = []
    for (var i = 0; i < folderModel.count; i++) {
      (function (idx) {
          console.log(service.pendingProcesses)
          var filePath = folderModel.get(idx, "filePath");
          var fileName = folderModel.get(idx, "fileName");
          var thumbnailPath = cacheDir + "/" + fileName;

          var thumbnailCmd = Utils.isVideo(fileName, service.filterVideos) ? videoToThumnailCmd(filePath, thumbnailPath) : imageToThumbnailCmd(filePath, thumbnailPath);
          var hexCmd = thumbnailHexValueCmd(thumbnailPath)

          const cmd = `
            [ -f ${thumbnailPath}* ] && exit 0
            ${thumbnailCmd}
            mv ${thumbnailPath} ${thumbnailPath}__x$(${hexCmd})
          `

          service.pendingProcesses++;
          var proc = processComponent.createObject(null, {
            command: ["bash", "-c", cmd]
          });

          proc.exited.connect(function () {
            service.pendingProcesses--;
            service.thumbnailRevision++;

            if (service.pendingProcesses === 0) {
              folderModel2.starting
            }

            proc.destroy();
          });

          proc.running = true;
          items.push({})
        })(i);

    }


    if (folderModel.count === 0) {
      service.loading = false;
    }

    files = items;
  }


  function imageToThumbnailCmd(filePath, thumbnailPath) {
    return `magick ${filePath} \
      -resize x500 \
      -quality 95 \
      ${thumbnailPath}
    `
  }

  function videoToThumnailCmd(filePath, thumbnailPath) {
    return `ffmpeg -y -i \
      ${filePath} \
      -vf select=eq(n\\,0),scale=-1:1080 \
      -frames:v 1 \
      -q:v 2 \
      ${thumbnailPath} </dev/null 2>/dev/null`
  }

  function thumbnailHexValueCmd(thumbnailPath) {
    return `magick ${thumbnailPath} -modulate 100,200 \
      -resize "1x1^" \
      -gravity center \
      -extent 1x1 \
      -depth 8 \
      -format "%[hex:p{0,0}]" info:- 2>/dev/null \
      | grep -oE '[0-9A-Fa-f]{6}' \
      | head -n 1`
  }

  FolderListModel {
    id: folderModel

    folder: service.wallpaperDir ? Qt.resolvedUrl("file://" + service.wallpaperDir) : ""
    nameFilters: Utils.nameFilters(service.filterImages, service.filterVideos)
    showDirs: false
    sortField: FolderListModel.Name

    onStatusChanged: {
      if (status === FolderListModel.Ready) {
        service.createThumbnails();
        folderModel2.running = true
      }
    }
  }

  FolderListModel {
    id: folderModel2

    nameFilters: ["*__x*"]
    showDirs: false
    sortField: FolderListModel.Name

    property bool running: false

    onRunningChanged: {
      folder = running ? Qt.resolvedUrl("file://" + service.cacheDir) : ""
    }

    onStatusChanged: {
      if (status === FolderListModel.Ready) {
        service.buildFileList();
      }
    }
  }

  Component {
    id: processComponent

    Process {
    }
  }
}

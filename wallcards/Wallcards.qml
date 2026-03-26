import "src"
// import "src/Utils.js" as Utils
import "scripts/KeyHandler.js" as KeyHandler
import qs.Commons
import qs.Widgets
import qs.Services.UI
import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel

PanelWindow {
  id: root

  property int animationDuration: cfg.animation_duration ?? defaults.animation_duration
  property color backgroundColor: cfg.background_color ?? defaults.background_color ?? "#333333"
  property real backgroundOpacity: cfg.background_opacity ?? defaults.background_opacity ?? 0.5
  property int cardHeight: cfg.card_height ?? defaults.card_height
  property int cardRadius: cfg.card_radius ?? defaults.card_radius
  property int cardSpacing: cfg.card_spacing ?? defaults.card_spacing
  property int cardStripWidth: cfg.card_strip_width ?? defaults.card_strip_width
  property int cardsShown: cfg.cards_shown ?? defaults.cards_shown
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  property var filterImages: cfg.filter_images ?? defaults.filter_images
  property var filterVideos: cfg.filter_videos ?? defaults.filter_videos
  property int filteredCount: filteredItems.length
  property var filteredItems: []
  property bool livePreview: cfg.live_preview ?? defaults.live_preview
  property bool loading: thumbnailService.loading
  property string loadingMessage: thumbnailService.loadingMessage
  property int pendingProcesses: 0
  property var pluginApi: null
  property string selectedFilter: cfg.selected_filter ?? defaults.selected_filter
  property var shearFactor: cfg.shear_factor ?? defaults.shear_factor
  property int thumbnailRevision: thumbnailService.thumbnailRevision
  property var topBarHeight: cfg.top_bar_height ?? defaults.top_bar_height
  property var topBarRadius: cfg.top_bar_radius ?? defaults.top_bar_radius

  signal quitRequested
  signal showRequested

  // function getFileName(idx) {
  //   return filteredItems.length === 0 ? "" : filteredItems[idx].fileName;
  // }

  // //
  // function getFilePath(idx) {
  //   return filteredItems.length === 0 ? "" : filteredItems[idx].filePath;
  // }

  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.layer: WlrLayer.Overlay
  aboveWindows: true
  color: "transparent"
  // exclusionMode: "Ignore"
  exclusiveZone: 0
  implicitHeight: screen.height
  implicitWidth: screen.width
  screen: pluginApi.panelOpenScreen

  ThumbnailService {
    id: thumbnailService

    cacheDir: root.pluginApi?.Settings.cacheDir + "/thumbnails/"
    filterImages: root.filterImages
    filterVideos: root.filterVideos
    wallpaperDir: root.pluginApi?.Settings.data.wallpaper.directory

    onReady: Logger.i("Wallcards", `${thumbnailService.thumbnailRevision} Thumbnails generated.`)
  }
  Rectangle {
    id: background

    anchors.fill: parent
    color: root.backgroundColor
    opacity: root.backgroundOpacity

    Behavior on opacity {
      NumberAnimation {
        duration: root.animationDuration
        easing.type: Easing.OutCubic
      }
    }

    Component.onCompleted: {
      opacity = root.backgroundOpacity;
    }

    MouseArea {
      anchors.fill: parent

      onClicked: root.quitRequested()
    }
  }

  //
  Item {
    id: content

    anchors.fill: parent
    focus: true

    Keys.onPressed: event => KeyHandler.handleKey(event, {
        [Qt.Key_Q]: () => root.quitRequested(),
        [Qt.Key_Escape]: () => root.quitRequested(),
        [Qt.Key_A]: () => root.selectedFilter = "all",
        [Qt.Key_I]: () => root.selectedFilter = "images",
        [Qt.Key_V]: () => root.selectedFilter = "videos",
        [Qt.Key_R]: () => console.log("ASHUFFFFFFFFFFFFFFELLE"),
        [Qt.Key_P]: () => root.livePreview = !root.livePreview
      })

    LoadingBar {
      id: loadingBar

      anchors.centerIn: parent
      pending: thumbnailService.pendingProcesses
      total: thumbnailService.fileCount
    }

    //
    TopBar {
      id: topBar

      anchors.bottom: cardDeck.top
      anchors.bottomMargin: root.topBarHeight / 3
      anchors.horizontalCenter: parent.horizontalCenter
      animationDuration: root.animationDuration
      currentIndex: 2
      filteredCount: root.filteredCount
      height: root.topBarHeight
      livePreview: root.livePreview
      opacity: 0.9
      pluginApi: root.pluginApi
      radius: root.topBarRadius
      selectedFilter: root.selectedFilter
      shearFactor: root.shearFactor
      visible: !loadingBar.visible
      width: cardDeck.width

      onFilterSelected: key => root.selectedFilter = key
      onLivePreviewToggled: root.livePreview = !root.livePreview
      onShuffleRequested: console.log("shuffle")
    }

    //
    CardDeck {
      id: cardDeck

      anchors.centerIn: parent
      cardRadius: root.cardRadius
      cardSpacing: root.cardSpacing
      cardStripWidth: root.cardStripWidth
      cardsShown: root.cardsShown
      height: root.cardHeight
      shearFactor: root.shearFactor
      visible: !loadingBar.visible
    }
  }
}

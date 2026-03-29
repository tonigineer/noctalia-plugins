import "src"
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

  property int animationCardsDuration: cfg.animation_duration ?? defaults.animation_duration ?? 1000
  property int animationWindowDuration: 500
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

  function close() {
    if (exitAnim.running)
      return;
    exitAnim.start();
  }

  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.layer: WlrLayer.Overlay
  aboveWindows: true
  color: "transparent"
  exclusiveZone: 0
  implicitHeight: screen.height
  implicitWidth: screen.width
  screen: pluginApi.panelOpenScreen

  ThumbnailService {
    id: thumbnailService

    cacheDir: root.pluginApi?.Settings.cacheDir
    filterImages: root.filterImages
    filterVideos: root.filterVideos
    wallpaperDir: root.pluginApi?.Settings.data.wallpaper.directory
  }

  //
  ParallelAnimation {
    id: exitAnim

    onFinished: root.quitRequested()

    NumberAnimation {
      duration: root.animationWindowDuration
      easing.type: Easing.InCubic
      property: "opacity"
      target: content
      to: 0
    }
    NumberAnimation {
      duration: root.animationWindowDuration
      easing.type: Easing.InCubic
      property: "scale"
      target: content
      to: 0.75
    }
    NumberAnimation {
      duration: root.animationWindowDuration
      easing.type: Easing.InCubic
      property: "opacity"
      target: background
      to: 0
    }
  }

  //
  Rectangle {
    id: background

    anchors.fill: parent
    color: root.backgroundColor

    NumberAnimation on opacity {
      duration: root.animationWindowDuration
      easing.type: Easing.OutCubic
      from: 0
      running: true
      to: root.backgroundOpacity
    }

    MouseArea {
      anchors.fill: parent

      onClicked: root.close()
    }
  }

  //
  Item {
    id: content

    anchors.fill: parent
    focus: true

    NumberAnimation on opacity {
      duration: root.animationWindowDuration
      easing.type: Easing.OutCubic
      from: 0
      running: true
      to: 1
    }

    //
    NumberAnimation on scale {
      duration: root.animationWindowDuration
      easing.overshoot: 0.5
      easing.type: Easing.OutBack
      from: 0.75
      running: true
      to: 1
    }

    Keys.onPressed: event => {
      // Shift — center card size
      if (event.modifiers & Qt.ShiftModifier) {
        if (event.key === Qt.Key_H) {
          root.cardHeight = Math.min(root.cardHeight + 10, 1200)
          event.accepted = true
          return
        } else if (event.key === Qt.Key_L) {
          root.cardHeight = Math.max(root.cardHeight - 10, 100)
          event.accepted = true
          return
        // } else if (event.key === Qt.Key_J) {
        //   root.cardStripWidth = Math.max(root.cardWidth - 5, 20)
        //   event.accepted = true
        //   return
        // } else if (event.key === Qt.Key_K) {
        //   root.cardStripWidth = Math.min(root.cardWidth + 5, 300)
        //   event.accepted = true
        //   return
        } else if (event.key === Qt.Key_N) {
          root.cardsShown = Math.max(root.cardsShown - 2, 3)
          event.accepted = true
          return
        } else if (event.key === Qt.Key_P) {
          root.cardsShown = Math.min(root.cardsShown + 2, 15)
          event.accepted = true
          return
        }
      }

      // Ctrl — spacing and strip width
      if (event.modifiers & Qt.ControlModifier) {
        if (event.key === Qt.Key_K) {
          root.cardSpacing = Math.min(root.cardSpacing + 2, 50);
          event.accepted = true;
          return;
        } else if (event.key === Qt.Key_J) {
          root.cardSpacing = Math.max(root.cardSpacing - 2, 0);
          event.accepted = true;
          return;
        } else if (event.key === Qt.Key_L) {
          root.cardStripWidth = Math.min(root.cardStripWidth + 5, 300);
          event.accepted = true;
          return;
        } else if (event.key === Qt.Key_H) {
          root.cardStripWidth = Math.max(root.cardStripWidth - 5, 20);
          event.accepted = true;
          return;
        } else if (event.key === Qt.Key_S) {
          root.pluginApi.saveSettings();
          event.accepted = true;
          return;
        }
      }

      // Normal keys
      KeyHandler.handleKey(event, {
        [Qt.Key_Question]: () => bottomBar.expanded = !bottomBar.expanded,
        [Qt.Key_Q]: () => root.close(),
        [Qt.Key_Escape]: () => root.close(),
        [Qt.Key_A]: () => root.selectedFilter = "all",
        [Qt.Key_I]: () => root.selectedFilter = "images",
        [Qt.Key_V]: () => root.selectedFilter = "videos",
        [Qt.Key_R]: () => {
          cardDeck.randomJump();
          topBar.flashShuffle();
        },
        [Qt.Key_P]: () => root.livePreview = !root.livePreview,
        [Qt.Key_K]: () => cardDeck.navigateTo(cardDeck.currentIndex + 1),
        [Qt.Key_J]: () => cardDeck.navigateTo(cardDeck.currentIndex - 1),
        [Qt.Key_L]: () => cardDeck.navigateTo(cardDeck.currentIndex + root.cardsShown - 2),
        [Qt.Key_H]: () => cardDeck.navigateTo(cardDeck.currentIndex - root.cardsShown + 2)
      });
    }

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
      anchors.horizontalCenterOffset: shearFactor * -root.topBarHeight * 4 / 3
      animationDuration: root.animationCardsDuration
      currentIndex: cardDeck.currentIndex
      filteredCount: thumbnailService.fileCount
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
      onShuffleRequested: cardDeck.randomJump()
    }

    //
    BottomBar {
      id: bottomBar

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: root.shearFactor * -root.topBarHeight * 4 / 3
      anchors.top: cardDeck.bottom
      anchors.topMargin: root.topBarHeight / 3
      opacity: 0.9
      shearFactor: root.shearFactor
      visible: !loadingBar.visible
    }
    //
    CardDeck {
      id: cardDeck

      anchors.centerIn: parent
      animationDuration: root.animationCardsDuration
      cardRadius: root.cardRadius
      cardSpacing: root.cardSpacing
      cardStripWidth: root.cardStripWidth
      cardsShown: root.cardsShown
      filteredCount: thumbnailService.fileCount
      height: root.cardHeight
      shearFactor: root.shearFactor
      visible: !loadingBar.visible

      onApplyRequested: index => console.log("Apply card:", index)
    }
  }
}

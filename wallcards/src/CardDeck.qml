import qs.Commons
import qs.Widgets
import QtQuick

Item {
  id: cardDeck

  required property int animationDuration
  property real animationIndex: 0
  required property int cardRadius
  required property int cardSpacing
  required property int cardStripWidth
  required property int cardsShown
  property real centerWidth: parent.width * centerWidthRatio
  required property real centerWidthRatio
  property real centerX: width / 2 - centerWidth / 2
  property int currentIndex: 0
  required property int filteredCount
  property int halfVisible: Math.floor(visibleCount / 2)
  property real runningIndex: 0
  required property real shearFactor
  property int sideCount: Math.floor(cardsShown / 2) - 1
  property int visibleCount: cardsShown

  required property string cacheDir
  required property var files
  required property var filterVideos

  function getFileName(idx) {
    if (files.length === 0 || idx < 0 || idx >= files.length) return "aaaaaaaaaaaaaaa"
    return files[idx].fileName
  }

  onFilesChanged: {
    if (currentIndex >= filteredCount && filteredCount > 0)
      currentIndex = 0
    runningIndex = currentIndex
    animationIndex = currentIndex
    revision++
  }

  property int revision: 0

  signal applyRequested(int index)

  function navigateTo(idx) {
    var newIdx = wrappedIndex(idx);
    var diff = 0;

    if (filteredCount > 0) {
      diff = newIdx - currentIndex;
      var half = filteredCount / 2;
      if (diff > half)
        diff -= filteredCount;
      else if (diff < -half)
        diff += filteredCount;
    }

    runningIndex += diff;
    animationIndex = runningIndex;
    currentIndex = newIdx;
  }
  function randomJump() {
    var rnd = Math.floor(Math.random() * filteredCount);
    if (rnd === currentIndex)
      rnd = (rnd + 1) % filteredCount;
    navigateTo(rnd);
  }
  function slotToWidth(slot) {
    var t = Math.min(Math.abs(slot), 1);
    return centerWidth + (cardStripWidth - centerWidth) * t;
  }
  function slotToX(slot) {
    if (slot >= 0 && slot <= 1)
      return centerX * (1 - slot) + (centerX + centerWidth + cardSpacing) * slot;
    if (slot >= -1 && slot < 0)
      return centerX * (1 + slot) + (centerX - cardSpacing - cardStripWidth) * -slot;
    if (slot > 1)
      return centerX + centerWidth + cardSpacing + (slot - 1) * (cardStripWidth + cardSpacing);
    if (slot < -1)
      return centerX - cardSpacing - cardStripWidth + (slot + 1) * (cardStripWidth + cardSpacing);
    return 0;
  }
  function wrappedIndex(idx) {
    return ((idx % filteredCount) + filteredCount) % filteredCount;
  }

  width: (cardsShown - 3) * cardStripWidth + (cardsShown - 3) * cardSpacing + centerWidth

  Behavior on animationIndex {
    NumberAnimation {
      duration: cardDeck.animationDuration
      easing.overshoot: 1
      easing.type: Easing.OutBack
    }
  }
  transform: Shear {
    xFactor: cardDeck.shearFactor
  }

  Repeater {
    model: cardDeck.filteredCount > 0 ? cardDeck.visibleCount : 0

    delegate: Card {
    }
  }
}

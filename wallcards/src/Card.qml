
import "Utils.js" as Utils
import qs.Commons
import qs.Widgets
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: card

  property string fileName: cardDeck.getFileName(modelIndex)
  property real fractionalSlot: offset + (cardDeck.runningIndex - cardDeck.animationIndex)
  property bool isCenter: offset === 0
  property int lastRevision: -1
  property int modelIndex: cardDeck.wrappedIndex(Math.round(cardDeck.runningIndex) + offset)
  property int offset: index - cardDeck.halfVisible
  property string thumbnailPath: fileName !== ""
    ? cardDeck.cacheDir + "/thumbnails/" + Utils.thumbnailName(fileName, cardDeck.filterVideos)
    : ""
  property string thumbnailSource: thumbnailPath !== "" ? "file://" + thumbnailPath : ""

  height: cardDeck.height
  opacity: Math.max(0, Math.min(1, cardDeck.halfVisible - Math.abs(fractionalSlot)))
  visible: (x + width) > 0 && x < cardDeck.width
  width: cardDeck.slotToWidth(fractionalSlot)
  x: cardDeck.slotToX(fractionalSlot)
  y: 0
  z: isCenter ? 100 : cardDeck.visibleCount - Math.abs(offset)

  Component.onCompleted: {
    img.source = card.thumbnailSource
  }

  Connections {
    target: cardDeck
    function onThumbnailRevisionChanged() {
      if (img.status === Image.Error || img.status === Image.Null) {
        if (cardDeck.thumbnailRevision !== card.lastRevision) {
          card.lastRevision = cardDeck.thumbnailRevision
          img.source = ""
          img.source = card.thumbnailSource
        }
      }
    }
    function onRevisionChanged() {
      img.source = ""
      img.source = card.thumbnailSource
    }
  }

  onModelIndexChanged: {
    var newSource = card.thumbnailSource
    if (img.source.toString() !== newSource) {
      imgOld.source = img.source
      imgOld.opacity = 1
      crossfade.restart()
      img.source = newSource
    }
  }

  onThumbnailPathChanged: {
    var newSource = card.thumbnailSource
    if (img.source.toString() !== newSource) {
      imgOld.source = img.source
      imgOld.opacity = 1
      crossfade.restart()
      img.source = newSource
    }
  }

  Connections {
    target: cardDeck
    function onThumbnailRevisionChanged() {
      if (img.status === Image.Error || img.status === Image.Null) {
        if (cardDeck.thumbnailRevision !== card.lastRevision) {
          card.lastRevision = cardDeck.thumbnailRevision
          img.source = ""
          img.source = card.thumbnailSource
        }
      }
    }
  }

  Item {
    id: imageFrame
    anchors.fill: parent
    clip: true

    Item {
      id: imgComposite
      width: cardDeck.centerWidth
      height: imageFrame.height
      x: (imageFrame.width - cardDeck.centerWidth) / 2
      visible: false

      Image {
        id: imgOld
        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        smooth: true
        sourceSize.height: parent.height
        sourceSize.width: cardDeck.centerWidth
      }

      Image {
        id: img
        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        smooth: true
        sourceSize.height: parent.height
        sourceSize.width: cardDeck.centerWidth
      }
    }

    NumberAnimation {
      id: crossfade
      target: imgOld
      property: "opacity"
      from: 1
      to: 0
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }

    Rectangle {
      id: mask
      anchors.fill: parent
      radius: cardDeck.cardRadius
      visible: false
    }

    OpacityMask {
      anchors.fill: parent
      maskSource: mask
      source: ShaderEffectSource {
        sourceItem: imgComposite
        sourceRect: Qt.rect(-imgComposite.x, 0, imageFrame.width, imageFrame.height)
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: cardDeck.cardRadius
      color: "transparent"
      border.width: card.isCenter ? Style.borderM : Style.borderS
      border.color: card.isCenter ? Color.mOutline : Color.mSurface
      z: 20
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: card.isCenter ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
      if (card.isCenter)
        cardDeck.applyRequested(card.modelIndex)
    }
    onWheel: function(wheel) {
      if (wheel.angleDelta.y > 0)
        cardDeck.navigateTo(cardDeck.currentIndex - 1)
      else if (wheel.angleDelta.y < 0)
        cardDeck.navigateTo(cardDeck.currentIndex + 1)
    }
  }
}

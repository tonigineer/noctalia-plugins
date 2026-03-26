import QtQuick
import qs.Commons

Item {
  id: deck

  required property int cardRadius
  required property int cardSpacing
  required property int cardStripWidth
  required property int cardsShown
  property real centerWidth: parent.width / 3
  property real centerX: width / 2 - centerWidth / 2
  required property real shearFactor
  property int sideCount: Math.floor(cardsShown / 2) - 1

  width: (cardsShown - 1) * cardStripWidth + (cardsShown - 1) * cardSpacing + centerWidth

  transform: Shear {
    xFactor: deck.shearFactor
  }

  // Center card
  Rectangle {
    border.color: Color.mOutline
    border.width: Style.borderM
    color: "transparent"
    height: deck.height
    radius: deck.cardRadius
    width: deck.centerWidth
    x: deck.centerX
    y: 0
  }

  // Left strips
  Repeater {
    model: deck.sideCount

    Rectangle {
      property int slot: index + 1

      border.color: Color.mSurface
      border.width: Style.borderS
      color: "transparent"
      height: deck.height
      opacity: Math.max(0, 1 - index * 0.2)
      radius: deck.cardRadius
      width: deck.cardStripWidth
      x: deck.centerX - deck.cardSpacing * slot - deck.cardStripWidth * slot
      y: 0
    }
  }

  // Right strips
  Repeater {
    model: deck.sideCount

    Rectangle {
      property int slot: index + 1

      border.color: Color.mSurface
      border.width: Style.borderS
      color: "transparent"
      height: deck.height
      opacity: Math.max(0, 1 - index * 0.2)
      radius: deck.cardRadius
      width: deck.cardStripWidth
      x: deck.centerX + deck.centerWidth + deck.cardSpacing * slot + deck.cardStripWidth * index
      y: 0
    }
  }
}

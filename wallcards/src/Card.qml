import QtQuick
import QtMultimedia
import Qt5Compat.GraphicalEffects
import qs.Commons
import qs.Widgets

Item {
  id: card

  required property int animationDuration
  required property int cardRadius
  required property real centerWidth
  required property string currentFileName
  required property bool isCenter
  required property bool isVideoFile
  required property bool loading
  required property string thumbnailSource
  required property string videoPath

  signal applyRequested
  signal scrollDown
  signal scrollUp

  function forceSource(source) {
    img.source = source;
  }

  // Public functions for thumbnail transitions
  function updateSource(newSource) {
    if (img.source.toString() !== newSource) {
      imgOld.source = img.source;
      imgOld.opacity = 1;
      crossfade.restart();
      img.source = newSource;
    }
  }

  // Image display
  Item {
    id: imageFrame

    anchors.fill: parent
    clip: true

    Item {
      id: imgComposite

      height: imageFrame.height
      visible: false
      width: card.centerWidth
      x: (imageFrame.width - card.centerWidth) / 2

      Image {
        id: imgOld

        anchors.fill: parent
        asynchronous: true
        cache: !card.loading
        fillMode: Image.PreserveAspectCrop
        smooth: true
        sourceSize.height: parent.height
        sourceSize.width: card.centerWidth
      }
      Image {
        id: img

        anchors.fill: parent
        asynchronous: true
        cache: !card.loading
        fillMode: Image.PreserveAspectCrop
        smooth: true
        sourceSize.height: parent.height
        sourceSize.width: card.centerWidth
      }
    }
    NumberAnimation {
      id: crossfade

      duration: Style.animationNormal
      easing.type: Easing.OutCubic
      from: 1
      property: "opacity"
      target: imgOld
      to: 0
    }
    Rectangle {
      id: mask

      anchors.fill: parent
      radius: card.cardRadius
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

    // Video preview
    Loader {
      id: videoLoader

      property string activeVideoPath: card.isCenter && card.isVideoFile ? card.videoPath : ""
      property bool shouldLoad: false

      active: shouldLoad && card.currentFileName !== ""
      anchors.fill: parent
      z: 5

      sourceComponent: Component {
        Item {
          id: videoContainer

          anchors.fill: parent
          layer.enabled: true
          opacity: 0

          layer.effect: OpacityMask {
            maskSource: Rectangle {
              height: videoContainer.height
              radius: card.cardRadius
              width: videoContainer.width
            }
          }

          MediaPlayer {
            id: mediaPlayer

            loops: MediaPlayer.Infinite
            source: "file://" + videoLoader.activeVideoPath
            videoOutput: videoOutput

            audioOutput: AudioOutput {
              volume: 0
            }

            Component.onCompleted: play()
            onPlayingChanged: {
              if (playing)
                videoFadeIn.start();
            }
          }
          VideoOutput {
            id: videoOutput

            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
          }
          NumberAnimation {
            id: videoFadeIn

            duration: Style.animationNormal
            easing.type: Easing.OutCubic
            from: 0
            property: "opacity"
            target: videoContainer
            to: 1
          }
        }
      }

      onActiveVideoPathChanged: {
        shouldLoad = false;
        if (activeVideoPath !== "")
          videoDelayTimer.restart();
        else
          videoDelayTimer.stop();
      }

      Timer {
        id: videoDelayTimer

        interval: card.animationDuration

        onTriggered: videoLoader.shouldLoad = true
      }
    }

    // Border
    Rectangle {
      id: border

      anchors.fill: parent
      border.color: card.isCenter ? Color.mOutline : Color.mSurface
      border.width: card.isCenter ? Style.borderM : Style.borderS
      color: "transparent"
      radius: card.cardRadius
      z: 20
    }
  }

  // Badges
  Badge {
    anchors.right: parent.right
    anchors.rightMargin: Style.marginM
    anchors.top: parent.top
    anchors.topMargin: Style.marginM
    icon: card.isVideoFile ? "video" : "image"
    text: card.currentFileName.split('.').pop().toUpperCase()
    visible: card.currentFileName !== ""
  }
  Badge {
    anchors.left: parent.left
    anchors.leftMargin: Style.marginM
    anchors.top: parent.top
    anchors.topMargin: Style.marginM
    text: card.currentFileName.substring(0, card.currentFileName.lastIndexOf('.'))
    visible: card.isCenter
  }
  Badge {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: Style.marginM
    icon: "info-circle"
    text: "Video wallpapers are coming soon."
    textColor: Color.mError
    visible: card.isCenter && card.isVideoFile
  }
  MouseArea {
    anchors.fill: parent
    cursorShape: card.isCenter ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: {
      if (card.isCenter)
        card.applyRequested();
    }
    onWheel: function (wheel) {
      if (wheel.angleDelta.y > 0)
        card.scrollUp();
      else if (wheel.angleDelta.y < 0)
        card.scrollDown();
    }
  }
}

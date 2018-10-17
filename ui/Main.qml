import QtMultimedia 5.9
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    id: root

    property alias stream: player.source
    property alias status: player.currentStatus
    property var albumimage
    property var title
    property int switchWidth: Kirigami.Units.gridUnit * 22
    backgroundDim: 0.7
    graceTime: Infinity
    backgroundImage: albumimage
    
    MediaPlayer {
        id: player
        autoPlay: true
        property var currentStatus

        onCurrentStatusChanged: {
            switch(currentStatus){
            case "stop":
                player.stop();
                break;
            case "pause":
                player.pause()
                break;
            case "resume":
                player.play()
                break;
            }
        }
    }
    
    Image {
        id: headerImg
        anchors.top: parent.top
        anchors.right: parent.right
        width: Kirigami.Units.gridUnit * 7
        height: Kirigami.Units.gridUnit * 7
        source: "images/soundcloud.png"
    }
    
    ColumnLayout {
        anchors.top: root.width > root.switchWidth ? headerImg.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: Kirigami.Units.largeSpacing

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: root.width > root.switchWidth ? 2 : 1

            Image {
                id: img
                fillMode: Image.PreserveAspectCrop
                Layout.preferredWidth: root.width > root.switchWidth ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: root.width > root.switchWidth ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 5
                source: albumimage
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Heading {
                    id: songtitle
                    text: title
                    level: root.width > root.switchWidth ? 1 : 3
                    Layout.fillWidth: true
                    font.capitalization: Font.Capitalize
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.largeSpacing

                    RoundButton {
                        id: previousButton
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                        focus: false
                        icon.name: "media-seek-backward"
                        onClicked: {
                            Mycroft.MycroftController.sendRequest("aiix.soundcloud-audio-player.previous", {});
                            previousButton.focus = false
                        }
                    }

                    RoundButton {
                        id: playButton
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 4
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                        focus: false
                        icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                        onClicked: {
                            player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                            playButton.focus = false
                        }
                    }

                    RoundButton {
                        id: nextButton
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                        focus: false
                        icon.name: "media-seek-forward"
                        onClicked: {
                            Mycroft.MycroftController.sendRequest("aiix.soundcloud-audio-player.next", {});
                            nextButton.focus = false
                        }
                    }
                }
                
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    Slider {
                        id: seekableslider
                        to: player.duration
                        Layout.preferredWidth: parent.implicitWidth - Kirigami.Units.gridUnit * 1.2
                        property bool sync: false

                        onValueChanged: {
                            if (!sync)
                                player.seek(value)
                        }

                        Connections {
                            target: player
                            onPositionChanged: {
                                seekableslider.sync = true
                                seekableslider.value = player.position
                                seekableslider.sync = false
                            }
                        }
                    }

                    Label {
                        id: positionLabel
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 1
                        readonly property int minutes: Math.floor(player.position / 60000)
                        readonly property int seconds: Math.round((player.position % 60000) / 1000)
                        text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"))
                    }
                }
            }
        }
    }
}

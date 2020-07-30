import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: delegateSoundHome
    skillBackgroundSource: Qt.resolvedUrl("music.jpg")
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0
    focus: true
    
    Component.onCompleted: {
        delegateSoundHome.forceActiveFocus()
    }
    
    ListModel {
        id: sampleModel

        ListElement {
            example: "soundcloud metallica"
            title: "metallica"
        }
        ListElement {
            example: "soundcloud electronic dance music"
            title: "electronic dance music"
        }
        ListElement {
            example: "soundcloud groove podcast"
            title: "groove podcast"
        }
        ListElement {
            example: "soundcloud ambient music"
            title: "ambient"
        }
        ListElement {
            example: "soundcloud jazz"
            title: "jazz"
        }
    }
    
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 2
        color: "#303030"
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
        }
        
        RowLayout {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            
            ToolButton {
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                flat: true
                
                contentItem: Image {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: Kirigami.Units.iconSizes.smallMedium
                    source: "images/back.png"
                }
                
                onClicked: {
                    delegateSoundHome.parent.backRequested()
                }
            }
            
            Kirigami.Heading {
                id: headingLabel
                level: 2
                text: "Soundcloud"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    
    Rectangle {
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: Qt.rgba(0, 0, 0, 0.7)

        ColumnLayout {
            id: root
            anchors.fill: parent

            Kirigami.Heading {
                level: 2
                font.bold: true
                text: "What can it do"
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                text: "Explore the latest artists, bands and creators of music & audio on Soundcloud"
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.largeSpacing
            }

            Kirigami.Heading {
                level: 2
                font.bold: true
                text: "Examples"
            }

            ListView {
                id: skillExampleListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                focus: false
                clip: true
                model: sampleModel
                spacing: Kirigami.Units.smallSpacing
                delegate: Kirigami.AbstractListItem {
                    id: rootCard

                    background: Kirigami.ShadowedRectangle {
                        color: rootCard.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        radius: Kirigami.Units.smallSpacing
                    }

                    contentItem: Label {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: Kirigami.Units.largeSpacing
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        color: Kirigami.Theme.textColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                        text: "Hey Mycroft, " + model.example
                    }

                    onClicked: {
                        triggerGuiEvent("aiix.soundcloud-audio-player.playtitle", {"playtitle": model.title})
                    }
                }
            }
        }
    }
}

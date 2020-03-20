import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    skillBackgroundSource: Qt.resolvedUrl("music.jpg")
        
    ColumnLayout {
        id: root
        anchors.fill: parent
        
        Item {
            height: Kirigami.Units.gridUnit * 5
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
            
            ColumnLayout {
                anchors.fill: parent
                
                RowLayout {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    
                    Image {
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        source: "https://cdn.iconscout.com/icon/free/png-256/soundcloud-2-101180.png"
                    }
                    
                    Kirigami.Heading {
                        level: 1
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        text: "Soundcloud" 
                    }
                }
                Kirigami.Heading {
                    level: 3
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    text: "Explore the latest artists, bands and creators of music & audio on Soundcloud" 
                }
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: hd2.contentHeight + Kirigami.Units.largeSpacing
                    color: Kirigami.Theme.linkColor
                    
                    Kirigami.Heading {
                        id: hd2
                        level: 3
                        width: parent.width
                        anchors.left: parent.left
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Some examples to get you started, try asking..."
                    }
                }
                                
                ListView {
                    id: skillExampleListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyNavigationEnabled: true
                    focus: true
                    highlightFollowsCurrentItem: true
                    snapMode: ListView.SnapToItem
                    model: sampleModel
                    delegate: Kirigami.BasicListItem {
                        id: rootCard
                        reserveSpaceForIcon: false
                        label: "Hey Mycroft, " + model.example
                        onClicked: {
                            triggerGuiEvent("aiix.soundcloud-audio-player.playtitle", {"playtitle": model.title})
                        }
                    }
                }
            }
        }
        
        Item {
            height: Kirigami.Units.gridUnit * 12
        }
    }
}

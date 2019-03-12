import QtMultimedia 5.9
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: root
    skillBackgroundSource: sessionData.audioThumbnail

    Mycroft.AudioPlayer {
        id: soundCloudPlayer
        anchors.fill: parent
        source: sessionData.audioSource
        thumbnail: sessionData.audioThumbnail
        title: sessionData.audioTitle
        nextAction: "aiix.soundcloud-audio-player.next"
        previousAction: "aiix.soundcloud-audio-player.previous"
        status: sessionData.status
    }
}

/*
 *  Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2018 Marco Martin <mart@kde.org>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import org.kde.kirigami 2.8 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen
import Mycroft 1.0 as Mycroft
import "+mediacenter/views" as Views
import "+mediacenter/delegates" as Delegates

Mycroft.Delegate {
    id: delegate

    property var scSearchModel: JSON.parse(sessionData.scSearchBlob)
    property var scCurrentSongUrl: sessionData.audioSource
    property var scCurrentTitle: sessionData.audioTitle

    skillBackgroundSource: "https://source.unsplash.com/1920x1080/?+music"
    fillWidth: true
    
    Keys.onBackPressed: {
        parent.parent.parent.currentIndex--
        parent.parent.parent.currentItem.contentItem.forceActiveFocus()
    }
    
    onFocusChanged: {
        if(focus) {
            relatedSongListView.view.forceActiveFocus()
        }
    }
    
    Views.TileView {
        id: relatedSongListView
        anchors.fill: parent
        title: "Related Music"
        cellWidth: view.width / 4
        cellHeight: cellWidth / 1.8 + Kirigami.Units.gridUnit * 5
        focus: true
        model: scSearchModel
        delegate: Delegates.SideAudioCard {
            width: relatedSongListView.cellWidth
            height: relatedSongListView.cellHeight
        }
    }
}


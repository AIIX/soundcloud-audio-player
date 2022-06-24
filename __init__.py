# -*- coding: utf-8 -*-

from __future__ import unicode_literals
import requests
from os.path import dirname
import sys
import youtube_dl
import json
from adapt.intent import IntentBuilder
from bs4 import BeautifulSoup
from mycroft.skills.core import MycroftSkill
from mycroft.messagebus.message import Message
import threading
import collections

__author__ = 'aix'
searchlst = {}
soundlst = []
searchlstobject = []
current_song = ""
 
class SoundcloudSkill(MycroftSkill):
    def __init__(self):
        super(SoundcloudSkill, self).__init__(name="SoundcloudSkill")
        self.process = None
        self.genMusicSearchList = None

    def initialize(self):
        self.load_data_files(dirname(__file__))
        
        self.add_event('soundcloud-audio-player.aiix.home', self.showHome)

        soundcloud = IntentBuilder("SoundcloudKeyword"). \
            require("SoundcloudKeyword").build()
        self.register_intent(soundcloud, self.soundcloud)
        
        soundcloudpause = IntentBuilder("SoundcloudPauseKeyword"). \
            require("SoundcloudPauseKeyword").build()
        self.register_intent(soundcloudpause, self.soundcloudpause)
        
        soundcloudresume = IntentBuilder("SoundcloudResumeKeyword"). \
            require("SoundcloudResumeKeyword").build()
        self.register_intent(soundcloudresume, self.soundcloudresume)
        
        soundcloudnext = IntentBuilder("SoundcloudNextKeyword"). \
            require("SoundcloudNextKeyword").build()
        self.register_intent(soundcloudnext, self.soundcloudnext)
        
        soundcloudprevious = IntentBuilder("SoundcloudPreviousKeyword"). \
            require("SoundcloudPreviousKeyword").build()
        self.register_intent(soundcloudprevious, self.soundcloudprevious)
        
        self.gui.register_handler('aiix.soundcloud-audio-player.next', self.soundcloudnext)
        self.gui.register_handler('aiix.soundcloud-audio-player.previous', self.soundcloudprevious)
        self.gui.register_handler('aiix.soundcloud-audio-player.playtitle', self.soundplayselection)

    def showHome(self, message):
        self.gui.clear()
        self.displayHome()
        
    def displayHome(self):
        self.gui.show_page("homepage.qml")
        
    def search(self, text):
        global soundlst
        global current_song
        query = text
        url = "https://soundcloud.com/search/sounds?q=" + query
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')
        for link in soup.find_all('h2'):
            for x in link.find_all('a'):
               r = x.get('href')
               countOfWords = collections.Counter(r)
               result = [i for i in countOfWords if countOfWords[i]>1]
               if "/" in result:
                 soundlst.append("https://soundcloud.com" + x.get('href'))
        
        if len(soundlst) != 0:
            genMusicUrl = soundlst[0]
            self.genMusicSearchList = threading.Thread(target=self.getSearchListInfo, args=[soundlst])
            self.genMusicSearchList.start()
            return genMusicUrl
        else:
            self.speak("No Song Found")
            return False
        
    def soundcloud(self, message):
        self.stop()
        global soundlst
        global current_song
        soundlst.clear()
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(
            message.data.get('SoundcloudKeyword'), '')
        aud = self.search(utterance)
        urlvideo = aud
        if urlvideo is not False:
            ydl_opts = {}
            with youtube_dl.YoutubeDL(ydl_opts) as ydl:
                info_dict = ydl.extract_info(urlvideo, download=False)
                audio_url = info_dict.get("url", None)
                audio_title = info_dict.get('title', None)
                audio_thumb = info_dict.get('thumbnail', None)
            print(audio_url, audio_title, audio_thumb)
            self.gui.clear()
            self.gui["audioTitle"] = str(audio_title)
            self.gui["audioSource"] = str(audio_url)
            self.gui["audioThumbnail"] = str(audio_thumb)
            self.gui["scSearchBlob"] = {} 
            self.gui["status"] = str("play")
            current_song = urlvideo
            print(current_song)
            self.gui.show_pages(["SoundCloudPlayer.qml", "SoundcloudSearch.qml"], 0, override_idle=True)
        
    def soundcloudpause(self, message):
        self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "status": str("pause")}))

    def soundcloudresume(self, message):
        self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "status": str("play")}))
        
    def soundcloudnext(self, message):
        global soundlst
        global current_song
        current_index = soundlst.index(current_song)
        if (current_index == len(soundlst)-1): 
            current_song = soundlst[0]
        else:
            current_song = soundlst[current_index+1]
            print(current_song)
                
        urlvideo = current_song
        ydl_opts = {}
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
                info_dict = ydl.extract_info(urlvideo, download=False)
                audio_url = info_dict.get("url", None)
                audio_title = info_dict.get('title', None)
                audio_thumb = info_dict.get('thumbnail', None)
        print(audio_url, audio_title, audio_thumb)
        self.gui["audioTitle"] = str(audio_title)
        self.gui["audioSource"] = str(audio_url)
        self.gui["audioThumbnail"] = str(audio_thumb)
        self.gui["scSearchBlob"] = {} 
        self.gui["status"] = str("play")
        current_song = urlvideo
        print(current_song)
        self.gui.show_page("SoundCloudPlayer.qml")
        
        
    def soundcloudprevious(self, message):
        global soundlst
        global current_song
        current_index = soundlst.index(current_song)
        if(current_index == 0):
            current_song = soundlst[len(soundlst)-1]
        else:
            current_song = soundlst[current_index - 1]
            print(current_song)
                
        urlvideo = current_song
        ydl_opts = {}
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            info_dict = ydl.extract_info(urlvideo, download=False)
            audio_url = info_dict.get("url", None)
            audio_title = info_dict.get('title', None)
            audio_thumb = info_dict.get('thumbnail', None)
        print(audio_url, audio_title, audio_thumb)
        self.gui["audioTitle"] = str(audio_title)
        self.gui["audioSource"] = str(audio_url)
        self.gui["audioThumbnail"] = str(audio_thumb)
        self.gui["scSearchBlob"] = {} 
        self.gui["status"] = str("play")
        current_song = urlvideo
        print(current_song)
        self.gui.show_page("SoundCloudPlayer.qml")

    def getSearchListInfo(self, soundlst):
        global searchlst
        global searchlstobject
        ydl_opts = {}
        ydl = youtube_dl.YoutubeDL(ydl_opts)
        searchlstobject.clear();
        for x in range(len(soundlst)):
            info_dict = ydl.extract_info(soundlst[x], download=False)
            searchlstobject.append({"title": info_dict.get("title", None), "url": info_dict.get("url", None), "thumbnail": info_dict.get("thumbnail", None)})
            result = json.dumps(searchlstobject)
            self.gui["scSearchBlob"] = result
            
        if self.genMusicSearchList is not None:
            sys.exit()
        else:
            print("process is None")
            
    def soundplayselection(self, message):
        self.stop()
        global soundlst
        global current_song
        soundlst.clear()
        utterance = message.data["playtitle"].lower()
        aud = self.search(utterance)
        urlvideo = aud
        if urlvideo is not False:
            ydl_opts = {}
            with youtube_dl.YoutubeDL(ydl_opts) as ydl:
                info_dict = ydl.extract_info(urlvideo, download=False)
                audio_url = info_dict.get("url", None)
                audio_title = info_dict.get('title', None)
                audio_thumb = info_dict.get('thumbnail', None)
            print(audio_url, audio_title, audio_thumb)
            self.gui["audioTitle"] = str(audio_title)
            self.gui["audioSource"] = str(audio_url)
            self.gui["audioThumbnail"] = str(audio_thumb)
            self.gui["scSearchBlob"] = {} 
            self.gui["status"] = str("play")
            current_song = urlvideo
            print(current_song)
            self.gui.show_pages(["SoundCloudPlayer.qml", "SoundcloudSearch.qml"], 0, override_idle=True)

    def stop(self):
        self.enclosure.bus.emit(Message("metadata", {"type": "stop"}))
        if self.process:
            self.process.terminate()
            self.process.wait()
        pass

def create_skill():
    return SoundcloudSkill()

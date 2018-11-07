# -*- coding: utf-8 -*-

from __future__ import unicode_literals
import requests
from os.path import dirname
import sys
import youtube_dl
from adapt.intent import IntentBuilder
from bs4 import BeautifulSoup
from mycroft.skills.core import MycroftSkill
from mycroft.messagebus.message import Message
import collections

__author__ = 'aix'
soundlst = []
current_song = ""
 
class SoundcloudSkill(MycroftSkill):
    def __init__(self):
        super(SoundcloudSkill, self).__init__(name="SoundcloudSkill")
        self.process = None

    def initialize(self):
        self.load_data_files(dirname(__file__))

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
        
        self.add_event('aiix.soundcloud-audio-player.next', self.soundcloudnext)
        self.add_event('aiix.soundcloud-audio-player.previous', self.soundcloudprevious)
        
    def search(self, text):
        global soundlst
        global current_song
        query = text
        url = "https://soundcloud.com/search?q=" + query
        response = requests.get(url)
        soup = BeautifulSoup(response.content, 'html.parser')
        for link in soup.find_all('h2'):
            for x in link.find_all('a'):
               r = x.get('href')
               countOfWords = collections.Counter(r)
               result = [i for i in countOfWords if countOfWords[i]>1]
               if "/" in result:
                 soundlst.append(x.get('href'))
        
        if len(soundlst) != 0:
            current_song = soundlst[0]
            genMusicUrl = "https://soundcloud.com" + current_song
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
            #self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "title": str(audio_title), "stream": str(audio_url), "albumimage": str(audio_thumb), "status": str("none")}))
            self.gui.clear()
            self.gui["title"] = str(audio_title)
            self.gui["stream"] = str(audio_url)
            self.gui["albumimage"] = str(audio_thumb)
            self.gui["status"] = str("none")
            self.gui.show_page("Main.qml")
        
    def soundcloudpause(self, message):
        self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "status": str("pause")}))

    def soundcloudresume(self, message):
        self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "status": str("resume")}))
        
    def soundcloudnext(self, message):
        global soundlst
        global current_song
        current_index = soundlst.index(current_song)
        if (current_index == len(soundlst)-1): 
            current_song = soundlst[0]
        else:
            current_song = soundlst[current_index+1]
            print(current_song)
                
        urlvideo = "https://soundcloud.com" + current_song
        ydl_opts = {}
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
                info_dict = ydl.extract_info(urlvideo, download=False)
                audio_url = info_dict.get("url", None)
                audio_title = info_dict.get('title', None)
                audio_thumb = info_dict.get('thumbnail', None)
        print(audio_url, audio_title, audio_thumb)
        #self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "title": str(audio_title), "stream": str(audio_url), "albumimage": str(audio_thumb), "status": str("none")}))
        self.gui.clear()
        self.gui["title"] = str(audio_title)
        self.gui["stream"] = str(audio_url)
        self.gui["albumimage"] = str(audio_thumb)
        self.gui["status"] = str("none")
        self.gui.show_page("Main.qml")
        
        
    def soundcloudprevious(self, message):
        global soundlst
        global current_song
        current_index = soundlst.index(current_song)
        if(current_index == 0):
            current_song = soundlst[len(soundlst)-1]
        else:
            current_song = soundlst[current_index - 1]
            print(current_song)
                
        urlvideo = "https://soundcloud.com" + current_song
        ydl_opts = {}
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            info_dict = ydl.extract_info(urlvideo, download=False)
            audio_url = info_dict.get("url", None)
            audio_title = info_dict.get('title', None)
            audio_thumb = info_dict.get('thumbnail', None)
        print(audio_url, audio_title, audio_thumb)
        #self.enclosure.bus.emit(Message("metadata", {"type": "soundcloud-audio-player", "title": str(audio_title), "stream": str(audio_url), "albumimage": str(audio_thumb), "status": str("none")}))
        self.gui.clear()
        self.gui["title"] = str(audio_title)
        self.gui["stream"] = str(audio_url)
        self.gui["albumimage"] = str(audio_thumb)
        self.gui["status"] = str("none")
        self.gui.show_page("Main.qml")


    def stop(self):
        self.enclosure.bus.emit(Message("metadata", {"type": "stop"}))
        if self.process:
            self.process.terminate()
            self.process.wait()
        pass

def create_skill():
    return SoundcloudSkill()

import requests
import json
from bs4 import BeautifulSoup
# from django.conf import settings

API_KEY =  "AIzaSyDCw5LJ75z1KekgHZLODoFafYTL5_T7lu4" #settings.YOUTUBE_API_KEY
YOUTUBE_URL_FORMAT = "https://youtube.com/watch?v={}"

URL = """https://www.googleapis.com/youtube/v3/search?part=snippet&
order=viewCount&
q=davido+dog&
type=video&
key=AIzaSyDCw5LJ75z1KekgHZLODoFafYTL5_T7lu4&
maxResults=30"""

def build_request(query):
    query = "+".join(query.split(" "))
    url = f"https://www.googleapis.com/youtube/v3/search?part=id,snippet&order=viewCount&q={query}&type=video&key={API_KEY}&maxResults=30"
    request = requests.get(url)
    if request.status_code == 200:
        jsonData = request.json()
        jsonData = jsonData['items']
        return jsonData
    else:
        raise Exception("Error occured")

def format_data(jsonData):
    data = []
    for _video in jsonData:
        video = {
            "id": _video["id"]["videoId"],
            "title": _video["snippet"]["title"],
            "description": _video["snippet"]["title"]
        }
        data.append(video)
    return video

# def get_mp3_source(id):
#     url = f"https://www.download-mp3-youtube.com/api/?api_key=MjcxMTg1NjMz&format=mp3&video_id={id}&button_color=11512f&text_color=dddddd"
#     ifHtml = requests.get(url)
#     soup = BeautifulSoup(ifHtml.context, "lxml")
#     # for div in soup.find_all("div", )


def get_video_source(id):
    youtube_url = YOUTUBE_URL_FORMAT.format(id)
    url = f"https://qdownloader.net/download?video={youtube_url}"
    request = requests.get(url)
    if request.status_code == 200:
        html = request.content
        soup = BeautifulSoup(html, "lxml")
        div = str(soup.select_one("div.downloadSection"))
        return div
    else:
        raise Exception("Error Occured")

def search_videos(query):
    jsonData = build_request(query)
    formatData = format_data(jsonData)
    return formatData

def get_video_info(id):
    url = f"https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id={id}&key={API_KEY}"
    request = requests.get(url)
    if request.status_code == 200:
        jsonData = request.json()
        jsonData = jsonData['items'][0]
        return jsonData
    else:
        raise Exception("Error occured")

# results = get_video_info("jR3y0bxKAvg")
# print(results)
# result = get_video_source("jR3y0bxKAvg")
# print(result)
from django.shortcuts import render
from django.http import JsonResponse
from .scraper.youtube import youtube
# Create your views here.
from django.contrib import messages
from urllib.parse import parse_qs, urlsplit

def home(request):
    return render(request, "index.html")

def converter(request):
    return render(request, "converter.html")

def download(request):
    video_id = request.GET["id"]
    video_format = request.GET["format"]
    context = {
        "download_key": "MjcxMTg1NjMz",
        "video_id":video_id,
        "format": video_format
    }
    try:
        video_info = youtube.get_video_info(video_id)
        video_div = youtube.get_video_source(video_id)
        context["video"] = video_info
        context["video_div"] = video_div
    except:
        messages.error(request, 'Error occured while trying to get the video source')
    
    return render(request, "download.html", context)

def play(request):
    video_id = request.GET["id"]
    context = {
        "video_id": video_id
    }
    try:
        video_info = youtube.get_video_info(video_id)
        context["video"] = video_info
    except:
        messages.error(request, 'Error occured while trying to get the video source')
    
    return render(request, "play.html", context)

def search(request):
    query = request.GET.get("q", None)
    if query is None:
        query = ""
    text = " ".join(query.split("+"))
    context = {
        "query": query,
        "text": text,
        "download_key": "MjcxMTg1NjMz"
    }
    return render(request, "search.html", context)

def extract_video_id(url):
    urlsplt = urlsplit(url).query
    url_queries = parse_qs(urlsplt)
    video_id = url_queries["v"][0]
    return video_id

def convert(request):
    video_url = request.GET["url"]
    video_id = extract_video_id(video_url)

    context = {
        "download_key": "MjcxMTg1NjMz",
        "video_id":video_id,
    }
    try:
        video_info = youtube.get_video_info(video_id)
        video_div = youtube.get_video_source(video_id)
        context["video"] = video_info
        context["video_div"] = video_div
    except:
        messages.error(request, 'Error occured while trying to get the video source')
    
    return render(request, "convert.html", context)

def search_youtube(request):
    if request.method == "GET":
        query = request.GET["q"]
        data = youtube.build_request(query)
        return JsonResponse(data=data, status=200, safe=False)
    else:
        return JsonResponse(data={"message":"Not allowed"}, status=405)
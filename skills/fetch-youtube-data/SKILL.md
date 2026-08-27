---
name: fetch-youtube-data
description: Fetch a YouTube transcript, description, and comments using the bundled Python workflow.
---

# Skill: fetch-youtube-data

Fetch YouTube video transcript, description, and comments using Python (youtube-transcript-api + yt-dlp).

## Usage

```bash
python fetch_youtube.py <VIDEO_ID>
```

## Requirements

```bash
pip install youtube-transcript-api yt-dlp
```

## Script: fetch_youtube.py

```python
import json
import sys
from youtube_transcript_api import YouTubeTranscriptApi
from yt_dlp import YoutubeDL

def fetch_youtube_data(video_id):
    url = f"https://www.youtube.com/watch?v={video_id}"
    result = {}
    
    # Get transcript
    print("=== FETCHING TRANSCRIPT ===")
    try:
        api = YouTubeTranscriptApi()
        transcript = api.fetch(video_id)
        transcript_list = [{'start': entry.start, 'duration': entry.duration, 'text': entry.text} for entry in transcript]
        result['transcript'] = transcript_list
        for entry in transcript[:5]:
            print(f"[{entry.start:.1f}s] {entry.text}")
        print(f"... ({len(transcript)} total entries)")
    except Exception as e:
        print(f"Error fetching transcript: {e}")
        result['transcript'] = []
    
    # Get video info (description, metadata)
    print("\n=== FETCHING VIDEO INFO ===")
    ydl_opts = {'quiet': True, 'skip_download': True}
    with YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)
        result['title'] = info.get('title')
        result['uploader'] = info.get('uploader')
        result['description'] = info.get('description', '')
        result['view_count'] = info.get('view_count')
        result['like_count'] = info.get('like_count')
        result['comment_count'] = info.get('comment_count')
        result['duration'] = info.get('duration')
        result['upload_date'] = info.get('upload_date')
        print(f"Title: {result['title']}")
        print(f"Uploader: {result['uploader']}")
        print(f"Views: {result['view_count']}")
        print(f"Description length: {len(result['description'])} chars")
    
    # Get comments
    print("\n=== FETCHING COMMENTS ===")
    ydl_opts_comments = {'quiet': True, 'skip_download': True, 'getcomments': True}
    with YoutubeDL(ydl_opts_comments) as ydl:
        info = ydl.extract_info(url, download=False)
        comments = info.get('comments', [])
        result['comments'] = comments
        print(f"Total comments: {len(comments)}")
        for i, comment in enumerate(comments[:5]):
            print(f"\n{i+1}. {comment.get('author', 'Unknown')}: {comment.get('text', '')[:150]}...")
    
    return result

if __name__ == "__main__":
    video_id = sys.argv[1] if len(sys.argv) > 1 else "LMmuhIwaeB4"
    data = fetch_youtube_data(video_id)
    
    # Save to file
    with open(f"youtube_data_{video_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"\nSaved to youtube_data_{video_id}.json")
```

## Example Output for Video LMmuhIwaeB4

**Title:** Pixal3D on 6GB VRAM — Better Than Trellis 2! (Free & Local)
**Channel:** PixelArtistry
**Views:** 68,585 | **Duration:** 18:59 | **Uploaded:** 2026-05-31

### Key Description Points:
- Pixal3D = Trellis 2 by Tencent + pixel-perfect front-view accuracy
- Runs on **6GB VRAM** via GGUF quantization (Q4 = 6GB, Q8 = more VRAM)
- MIT license, free for commercial use
- Requires: NVIDIA RTX 20-series+, CUDA, Coffee Hour Easy Install (Python 3.12, Torch 2.8, CUDA 12.8)
- Resources: https://pixel-artistry.com/Pixal3DGGUF
- Workflows + install scripts at the link above

### ComfyUI Workflow (from transcript):
1. **Load Model**: Trellis 2 Load Model GGUF → select XL 3D GGUF, Q4 for 6GB VRAM
2. **Pre-process**: TripoSR pre-process image node → enable "remove background"
3. **Generate**: Run workflow (first run downloads models, ~196s)
4. **Texture**: Pixal3D texturing is weaker; combine with TripoSR mesh texturing for better results
5. **Settings**: Flash Attention backend, sparse structure steps/resolution adjustable
6. **Full model**: ~12GB (shape) + 16GB (texture) VRAM

### Key Workflow Files mentioned:
- `trellis2_gguf.bat` installer (Error-X fork)
- VisualBruno's ComfyUI-Trellis2 nodes
- Workflows linked in video description

### Top Comments:
1. **@BorisBrock**: "Limiting to NVIDIA GPUs is bad - why no AMD/Intel/Mac support?"
2. **@wot5183**: Questions about dual GPU (2060 Super + Tesla P100 16GB) and Q5/Q6 VRAM usage
3. **@alphawolf2993**: "Any hope for AMD? I have 7800XT 16GB"
4. **@minhhieule4064**: RTX 4080 getting "Not enough GPU memory" error
5. **@oscar_manyoses_VFX**: Workflow names in video don't match Drive download links
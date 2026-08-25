# YouTube Transcript Fetcher Skill

Fetch YouTube video transcripts, descriptions, and metadata using yt-dlp.

## Usage

```bash
# Get transcript
agent-browser youtube-transcript <video_url_or_id>

# Get full metadata (title, description, chapters, etc.)
agent-browser youtube-transcript --full <video_url_or_id>

# Save transcript to file
agent-browser youtube-transcript -o transcript.txt <video_url_or_id>
```

## Install

```bash
pip install yt-dlp
```

## Examples

```bash
# From URL
agent-browser youtube-transcript "https://www.youtube.com/watch?v=FuFm8zBHDWI"

# From video ID
agent-browser youtube-transcript FuFm8zBHDWI

# Get full metadata including description and chapters
agent-browser youtube-transcript --full "https://www.youtube.com/watch?v=FuFm8zBHDWI"
```
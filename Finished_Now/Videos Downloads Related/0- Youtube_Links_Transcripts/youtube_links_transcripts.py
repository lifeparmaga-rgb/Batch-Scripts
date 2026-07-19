#!/usr/bin/env python3
"""
Fetches Arabic transcripts for a list of YouTube video links from a text file.
Use this when you already have a file containing video links (not a playlist URL).

Setup before running:
    pip install -U yt-dlp

Usage:
    python youtube_links_transcripts.py
    It will ask for the path to a .txt file containing one video link per line
    (any line starting with # is treated as a comment and skipped).

Features:
    - Resume: if the script stops, videos already processed are not redone.
      Resume is keyed on the VIDEO ID, so it is NOT affected by reordering,
      inserting, or removing lines in the input file between runs.
    - Retry with exponential backoff on HTTP 429 (Too Many Requests).
    - Random delay between videos + longer cooldowns every N videos.
    - Arabic text cleanup (Unicode NFC normalization + removal of hidden
      bidi control characters).

Scope note:
    This script fetches *native* Arabic subtitles only - i.e. manually
    uploaded Arabic subtitles or YouTube's Arabic auto-generated captions.
    It does NOT request YouTube's machine-translated-into-Arabic tracks
    (e.g. translating English captions to Arabic), because yt-dlp's support
    for those is unreliable. A video with only non-Arabic captions is
    therefore reported as having no Arabic transcript.
"""

import os
import re
import sys
import time
import glob
import random
import unicodedata
import yt_dlp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

# ============ SETTINGS ============
OUTPUT_DIR = "transcripts"
LANGS = ["ar"]

MIN_DELAY = 8            # minimum delay between videos (seconds)
MAX_DELAY = 18           # maximum delay between videos (seconds)

COOLDOWN_EVERY = 10       # take a longer break every N videos
COOLDOWN_MIN = 90
COOLDOWN_MAX = 150

MAX_RETRIES_429 = 5
BACKOFF_BASE = 60

KEEP_VTT = False          # keep the raw .vtt subtitle files after conversion

# Set a browser name ("chrome", "edge", "firefox", "brave") to use cookies
COOKIES_FROM_BROWSER = None
# ===================================

os.makedirs(OUTPUT_DIR, exist_ok=True)

BIDI_CONTROL_CHARS = re.compile(
    "[\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069]"
)

VIDEO_ID_RE = re.compile(r"(?:v=|youtu\.be/|/shorts/|/embed/)([a-zA-Z0-9_-]{11})")


def extract_video_id(text):
    m = VIDEO_ID_RE.search(text)
    if m:
        return m.group(1)
    if re.fullmatch(r"[a-zA-Z0-9_-]{11}", text):
        return text
    return None


def load_links(file_path):
    video_ids = []
    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            # Supports tab-separated export format (idx\tid\ttitle\turl) or a plain link
            candidate = line.split("\t")[-1] if "\t" in line else line
            vid = extract_video_id(candidate)
            if vid:
                video_ids.append(vid)
            else:
                print(f"  [warning] Unrecognized line, skipped: {line}")
    # De-duplicate while preserving the original order so the same video is
    # never downloaded twice within a single run.
    deduped = list(dict.fromkeys(video_ids))
    removed = len(video_ids) - len(deduped)
    if removed:
        print(f"  [info] Removed {removed} duplicate link(s) from the list.")
    return deduped


def clean_arabic_text(text):
    text = unicodedata.normalize("NFC", text)
    text = BIDI_CONTROL_CHARS.sub("", text)
    text = text.replace("ـ", "")
    text = re.sub(r"[ \t]+", " ", text)
    return text.strip()


def vtt_to_text(vtt_path):
    with open(vtt_path, "r", encoding="utf-8-sig", errors="ignore") as f:
        lines = f.readlines()

    text_lines = []
    prev = None
    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith(("WEBVTT", "Kind:", "Language:")):
            continue
        if "-->" in line or re.match(r"^\d\d:\d\d:\d\d", line):
            continue
        if line.isdigit():
            continue
        clean = re.sub(r"<[^>]+>", "", line)
        clean = clean_arabic_text(clean)
        # Only collapse CONSECUTIVE duplicate lines (YouTube's rolling captions
        # repeat the same line across adjacent cues). A line that genuinely
        # recurs later in the video is kept.
        if clean and clean != prev:
            text_lines.append(clean)
            prev = clean

    return "\n".join(text_lines)


def find_existing_txt(video_id):
    """Return the path of an already-saved transcript for this video id,
    regardless of any index prefix used when it was first saved."""
    matches = glob.glob(os.path.join(OUTPUT_DIR, f"*_{video_id}.txt"))
    matches += glob.glob(os.path.join(OUTPUT_DIR, f"{video_id}.txt"))
    return matches[0] if matches else None


def download_with_retry(video_id, base_name, url):
    ydl_opts = {
        "skip_download": True,
        "writesubtitles": True,
        "writeautomaticsub": True,
        "subtitleslangs": LANGS,
        "subtitlesformat": "vtt",
        "outtmpl": base_name,
        "quiet": True,
        "no_warnings": True,
        "retries": 3,
        "fragment_retries": 3,
        "sleep_interval_requests": 1,
        "sleep_interval_subtitles": 3,
    }
    if COOKIES_FROM_BROWSER:
        ydl_opts["cookiesfrombrowser"] = (COOKIES_FROM_BROWSER,)

    for attempt in range(1, MAX_RETRIES_429 + 1):
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
            return info
        except Exception as e:
            err = str(e)
            if "429" in err and attempt < MAX_RETRIES_429:
                wait = BACKOFF_BASE * (2 ** (attempt - 1))
                print(f"  [wait] 429 rate limit - waiting {wait}s before retry ({attempt}/{MAX_RETRIES_429})...")
                time.sleep(wait)
                continue
            print(f"  [error] Final failure for video {video_id}: {err}")
            return None
    return None


def process_video(video_id, idx):
    """Returns one of: 'skipped', 'done', 'failed'."""
    # Resume check is keyed on the video id, so it survives list reordering.
    existing = find_existing_txt(video_id)
    if existing:
        print(f"  [skip] Already done: {video_id}")
        return "skipped"

    base_name = os.path.join(OUTPUT_DIR, f"{idx:03d}_{video_id}")
    url = f"https://www.youtube.com/watch?v={video_id}"
    info = download_with_retry(video_id, base_name, url)
    if info is None:
        return "failed"

    title = info.get("title") or video_id

    found_vtt = f"{base_name}.ar.vtt"
    if not os.path.exists(found_vtt):
        found_vtt = None
        for fname in os.listdir(OUTPUT_DIR):
            if fname.startswith(os.path.basename(base_name)) and fname.endswith(".vtt"):
                found_vtt = os.path.join(OUTPUT_DIR, fname)
                break

    if not found_vtt:
        print(f"  [missing] No native Arabic transcript (manual or auto-generated) for: {title}")
        return "failed"

    text = vtt_to_text(found_vtt)
    if not text:
        print(f"  [empty] Arabic transcript is empty for: {title}")
        if not KEEP_VTT:
            try:
                os.remove(found_vtt)
            except OSError:
                pass
        return "failed"

    with open(f"{base_name}.txt", "w", encoding="utf-8", newline="\n") as f:
        f.write(f"Title: {title}\nVideo URL: {url}\n\n")
        f.write(text)

    if not KEEP_VTT:
        try:
            os.remove(found_vtt)
        except OSError:
            pass

    print(f"  [done] {title}")
    return "done"


def main():
    file_path = input("Enter the path to the links file (.txt): ").strip()
    if not os.path.isfile(file_path):
        print("File not found, check the path.")
        return

    print("Reading links from file...")
    video_ids = load_links(file_path)
    total = len(video_ids)
    print(f"Valid video count: {total}\n")

    done_new, skipped, failed = 0, 0, []
    for idx, vid in enumerate(video_ids, start=1):
        print(f"[{idx}/{total}] {vid}")
        status = process_video(vid, idx)
        if status == "done":
            done_new += 1
        elif status == "skipped":
            skipped += 1
        else:
            failed.append(vid)

        # Only pause when we actually hit the network (i.e. not on a skip).
        if idx < total and status != "skipped":
            if idx % COOLDOWN_EVERY == 0:
                wait = random.randint(COOLDOWN_MIN, COOLDOWN_MAX)
                print(f"  [cooldown] Resting {wait}s after {COOLDOWN_EVERY} videos...")
                time.sleep(wait)
            else:
                time.sleep(random.randint(MIN_DELAY, MAX_DELAY))

    print(f"\nDownloaded now: {done_new} | Already had: {skipped} | Failed: {len(failed)}")
    print(f"Files are in: {OUTPUT_DIR}/")

    if failed:
        report_path = os.path.join(OUTPUT_DIR, "_videos_without_arabic_transcript.txt")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write("Videos that failed or have no Arabic transcript:\n\n")
            for vid in failed:
                f.write(f"https://www.youtube.com/watch?v={vid}\n")
        print(f"Missing videos report: {report_path}")


if __name__ == "__main__":
    main()

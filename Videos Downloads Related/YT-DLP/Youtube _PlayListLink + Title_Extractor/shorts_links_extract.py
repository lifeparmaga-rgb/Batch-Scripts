from yt_dlp import YoutubeDL

file_name = input("Enter File That I Will Extract Links Into It")
def get_shorts_links(channel_url, output_file=file_name):
    ydl_opts = {
        "extract_flat": True,  
        "quiet": True,
    }

    with YoutubeDL(ydl_opts) as ydl:
        print(f"Fetching Shorts from: {channel_url}")
        info = ydl.extract_info(channel_url, download=False)

        links = []
        for entry in info.get("entries", []):
            video_id = entry.get("id")
            if video_id:
                link = f"https://www.youtube.com/watch?v={video_id}"
                links.append(link)

        
        with open(output_file, "w", encoding="utf-8") as f:
            for link in links:
                f.write(link + "\n")

        print(f"✅ تم استخراج {len(links)} لينك وحفظهم في {output_file}")


if __name__ == "__main__":
    
    channel_shorts_url = input("Enter Channel_Shorts_Url")
    get_shorts_links(channel_shorts_url)

import os
import sys
import re
from yt_dlp import YoutubeDL


def sanitize_filename(name):
    """إزالة الأحرف غير المسموح بها في أسماء الملفات"""
    name = re.sub(r'[\\/*?:"<>|]', "_", name)
    name = name.strip(". ")
    return name or "output"


def detect_url_type(url):
    """تحديد نوع اللينك: shorts أو playlist"""
    url_lower = url.lower()
    if "/shorts" in url_lower:
        return "shorts"
    elif "list=" in url_lower or "/playlist" in url_lower:
        return "playlist"
    elif "/@" in url_lower or "/channel/" in url_lower or "/c/" in url_lower or "/user/" in url_lower:
        return "channel"
    return "unknown"


def get_channel_name(url):
    """استخراج اسم صاحب القناة"""
    ydl_opts = {
        "extract_flat": True,
        "quiet": True,
        "no_warnings": True,
        "playlist_items": "1",  # نجيب item واحد بس للسرعة
    }
    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            # نحاول نجيب اسم القناة من الـ uploader أو channel
            channel = (
                info.get("uploader")
                or info.get("channel")
                or info.get("title")
                or "channel"
            )
            return sanitize_filename(channel)
    except Exception:
        return "channel"


def get_playlist_name(url):
    """استخراج اسم قائمة التشغيل"""
    ydl_opts = {
        "extract_flat": True,
        "quiet": True,
        "no_warnings": True,
    }
    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            title = info.get("title") or "playlist"
            return sanitize_filename(title)
    except Exception:
        return "playlist"


def extract_links(url):
    """استخراج كل اللينكات من الـ URL المعطى"""
    ydl_opts = {
        "extract_flat": True,
        "quiet": True,
        "no_warnings": True,
    }
    links = []
    try:
        with YoutubeDL(ydl_opts) as ydl:
            print("⏳ جاري استخراج اللينكات...")
            info = ydl.extract_info(url, download=False)

            entries = info.get("entries", [])

            # لو في entries متداخلة (مثلاً قناة فيها playlists)
            for entry in entries:
                if entry is None:
                    continue
                # لو الـ entry نفسه playlist
                sub_entries = entry.get("entries")
                if sub_entries:
                    for sub in sub_entries:
                        if sub and sub.get("id"):
                            links.append(f"https://www.youtube.com/watch?v={sub['id']}")
                elif entry.get("id"):
                    links.append(f"https://www.youtube.com/watch?v={entry['id']}")

    except Exception as e:
        print(f"❌ خطأ أثناء الاستخراج: {e}")
        sys.exit(1)

    return links


def main():
    print("=" * 50)
    print("  🎬 YouTube Links Extractor")
    print("=" * 50)

    url = input("\nأدخل لينك القناة أو قائمة التشغيل:\n> ").strip()

    if not url:
        print("❌ لم تدخل أي لينك!")
        sys.exit(1)

    url_type = detect_url_type(url)
    print(f"\n🔍 نوع اللينك المكتشف: {url_type}")

    # تحديد اسم الملف حسب النوع
    if url_type == "playlist":
        print("📋 جاري جلب اسم قائمة التشغيل...")
        name = get_playlist_name(url)
        output_file = f"{name}_playlist_links.txt"
    elif url_type in ("shorts", "channel"):
        print("👤 جاري جلب اسم صاحب القناة...")
        name = get_channel_name(url)
        suffix = "shorts_links" if url_type == "shorts" else "channel_links"
        output_file = f"{name}_{suffix}.txt"
    else:
        # نحاول نجيب الاسم على أي حال
        print("⚠️  نوع اللينك غير واضح، جاري المحاولة...")
        name = get_channel_name(url)
        output_file = f"{name}_links.txt"

    # مسار الملف في نفس مجلد الإسكريبت
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, output_file)

    # استخراج اللينكات
    links = extract_links(url)

    if not links:
        print("⚠️  لم يتم العثور على أي لينكات!")
        sys.exit(1)

    # حفظ الملف
    with open(output_path, "w", encoding="utf-8") as f:
        for link in links:
            f.write(link + "\n")

    print(f"\n✅ تم استخراج {len(links)} لينك")
    print(f"📁 تم الحفظ في: {output_path}")
    print("=" * 50)


if __name__ == "__main__":
    main()

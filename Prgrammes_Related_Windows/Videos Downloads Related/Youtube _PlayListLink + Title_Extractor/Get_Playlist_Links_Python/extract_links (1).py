import os
import sys
import re
from datetime import datetime, timedelta
from yt_dlp import YoutubeDL

try:
    from tqdm import tqdm
    TQDM_AVAILABLE = True
except ImportError:
    TQDM_AVAILABLE = False


# ─────────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────────

def sanitize_filename(name):
    name = re.sub(r'[\\/*?:"<>|]', "_", name)
    return name.strip(". ") or "output"


def detect_url_type(url):
    u = url.lower()
    if "/shorts" in u:
        return "shorts"
    if "list=" in u or "/playlist" in u:
        return "playlist"
    if "/@" in u or "/channel/" in u or "/c/" in u or "/user/" in u:
        return "channel"
    return "unknown"


def get_meta_name(url, url_type):
    """جلب اسم القناة أو قائمة التشغيل"""
    ydl_opts = {"extract_flat": True, "quiet": True,
                "no_warnings": True, "playlist_items": "1"}
    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            if url_type == "playlist":
                return sanitize_filename(info.get("title") or "playlist")
            return sanitize_filename(
                info.get("uploader") or info.get("channel") or info.get("title") or "channel"
            )
    except Exception:
        return "channel"


def ask_date_filter():
    """سؤال المستخدم عن فلتر التاريخ"""
    print("\n📅 فلترة حسب التاريخ:")
    print("  1) بدون فلترة (كل الفيديوهات)")
    print("  2) آخر أسبوع")
    print("  3) آخر شهر")
    print("  4) آخر 3 أشهر")
    print("  5) آخر سنة")
    print("  6) تاريخ مخصص (YYYY-MM-DD)")

    choice = input("\nاختر [1-6]: ").strip()

    now = datetime.now()
    if choice == "1":
        return None
    elif choice == "2":
        return now - timedelta(weeks=1)
    elif choice == "3":
        return now - timedelta(days=30)
    elif choice == "4":
        return now - timedelta(days=90)
    elif choice == "5":
        return now - timedelta(days=365)
    elif choice == "6":
        raw = input("أدخل التاريخ (YYYY-MM-DD): ").strip()
        try:
            return datetime.strptime(raw, "%Y-%m-%d")
        except ValueError:
            print("⚠️  تاريخ غير صحيح، هيتم تجاهل الفلترة.")
            return None
    return None


def is_valid_entry(entry):
    """تجاهل الفيديوهات المحذوفة أو الخاصة"""
    if not entry or not entry.get("id"):
        return False
    title = (entry.get("title") or "").lower()
    if title in ("[deleted]", "[private]", "[unavailable]", ""):
        return False
    availability = entry.get("availability", "")
    if availability in ("private", "premium_only", "subscriber_only"):
        return False
    return True


# ─────────────────────────────────────────────
#  Main extractor
# ─────────────────────────────────────────────

def extract_links(url, date_filter=None):
    ydl_opts = {
        "extract_flat": True,
        "quiet": True,
        "no_warnings": True,
    }

    raw_entries = []
    try:
        with YoutubeDL(ydl_opts) as ydl:
            print("\n⏳ جاري جلب قائمة الفيديوهات...")
            info = ydl.extract_info(url, download=False)
            entries = info.get("entries", [])

            # فك التداخل لو في playlists جوّا قناة
            for entry in entries:
                if entry is None:
                    continue
                sub = entry.get("entries")
                if sub:
                    raw_entries.extend(sub)
                else:
                    raw_entries.append(entry)

    except Exception as e:
        print(f"\n❌ خطأ أثناء الاستخراج: {e}")
        sys.exit(1)

    total_raw = len(raw_entries)
    print(f"📦 إجمالي الفيديوهات المجلوبة: {total_raw}")

    links = []
    seen_ids = set()
    skipped_deleted = 0
    skipped_duplicate = 0
    skipped_date = 0

    iterator = tqdm(raw_entries, desc="🔍 معالجة", unit="فيديو") if TQDM_AVAILABLE else raw_entries

    for entry in iterator:
        # تجاهل المحذوف والخاص
        if not is_valid_entry(entry):
            skipped_deleted += 1
            continue

        vid_id = entry["id"]

        # إزالة المكرر
        if vid_id in seen_ids:
            skipped_duplicate += 1
            continue
        seen_ids.add(vid_id)

        # فلترة التاريخ
        if date_filter:
            upload_date = entry.get("upload_date")  # YYYYMMDD string
            if upload_date:
                try:
                    vid_date = datetime.strptime(upload_date, "%Y%m%d")
                    if vid_date < date_filter:
                        skipped_date += 1
                        continue
                except ValueError:
                    pass  # لو التاريخ غير صحيح نشمله عادي

        links.append(f"https://www.youtube.com/watch?v={vid_id}")

    return links, {
        "total_raw": total_raw,
        "kept": len(links),
        "skipped_deleted": skipped_deleted,
        "skipped_duplicate": skipped_duplicate,
        "skipped_date": skipped_date,
    }


# ─────────────────────────────────────────────
#  Entry point
# ─────────────────────────────────────────────

def main():
    print("=" * 55)
    print("   🎬  YouTube Links Extractor  —  yt-dlp ready")
    print("=" * 55)

    if not TQDM_AVAILABLE:
        print("💡 نصيحة: ثبّت tqdm للحصول على شريط تقدم:  pip install tqdm\n")

    url = input("\nأدخل لينك القناة أو قائمة التشغيل:\n> ").strip()
    if not url:
        print("❌ لم تدخل أي لينك!")
        sys.exit(1)

    url_type = detect_url_type(url)
    print(f"🔍 نوع اللينك: {url_type}")

    # فلتر التاريخ
    date_filter = ask_date_filter()

    # اسم الملف
    print("\n👤 جاري جلب اسم القناة / القائمة...")
    name = get_meta_name(url, url_type)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    if url_type == "playlist":
        output_file = f"{name}_playlist_{timestamp}.txt"
    elif url_type == "shorts":
        output_file = f"{name}_shorts_{timestamp}.txt"
    else:
        output_file = f"{name}_links_{timestamp}.txt"

    # مسار الإسكريبت
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, output_file)

    # استخراج
    links, stats = extract_links(url, date_filter)

    if not links:
        print("\n⚠️  لم يتم العثور على أي لينكات بعد الفلترة!")
        sys.exit(1)

    # حفظ — لينكات فقط، جاهزة لـ yt-dlp -a
    with open(output_path, "w", encoding="utf-8") as f:
        for link in links:
            f.write(link + "\n")

    # ملخص
    print("\n" + "=" * 55)
    print(f"  ✅  تم الحفظ بنجاح!")
    print(f"  📁  المسار : {output_path}")
    print(f"  🔗  محفوظ  : {stats['kept']} لينك")
    if stats['skipped_deleted']:
        print(f"  🗑️  محذوف/خاص مُتجاهَل : {stats['skipped_deleted']}")
    if stats['skipped_duplicate']:
        print(f"  🔁  مكرر مُزال          : {stats['skipped_duplicate']}")
    if stats['skipped_date']:
        print(f"  📅  خارج نطاق التاريخ  : {stats['skipped_date']}")
    print("=" * 55)
    print(f"\n▶️  لتنزيل الكل:")
    print(f"    yt-dlp -a \"{output_file}\"")
    print("=" * 55)


if __name__ == "__main__":
    main()

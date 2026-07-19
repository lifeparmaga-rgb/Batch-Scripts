import os
import re

def extract_bookmarks(data):
    # يلتقط التوقيتات زي 17.3651 =
    matches = re.findall(r'(\d+(?:\.\d+)?)\s*=', data)

    bookmarks = []
    for i, t in enumerate(matches):
        try:
            seconds = float(t)
            ms = int(seconds * 1000)
            bookmarks.append(f"{ms}|Bookmark {i+1}")
        except:
            pass

    return bookmarks


def convert_file(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8', errors='ignore') as f:
        data = f.read()

    bookmarks = extract_bookmarks(data)

    if not bookmarks:
        return 0

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(bookmarks))

    return len(bookmarks)


def process_folder(root_dir):
    total_files = 0

    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith(".gom"):
                gom_path = os.path.join(root, file)

                pbf_path = os.path.join(
                    root,
                    os.path.splitext(file)[0] + ".pbf"
                )

                count = convert_file(gom_path, pbf_path)

                if count > 0:
                    print(f"[OK] {gom_path} -> {count} bookmarks")
                    total_files += 1
                else:
                    print(f"[SKIP] {gom_path} (no bookmarks found)")

    print(f"\nDone! Converted {total_files} files.")


# 🚀 شغل من نفس المجلد الحالي
if __name__ == "__main__":
    process_folder(".")
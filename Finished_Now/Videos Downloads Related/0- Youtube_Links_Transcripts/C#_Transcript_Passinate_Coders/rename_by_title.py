# -*- coding: utf-8 -*-
"""
سكريبت إعادة تسمية ملفات الترانسكريبت
========================================
يشتغل على كل ملفات .txt الموجودة فى نفس مجلد السكريبت.

طريقة التسمية:
- الجزء الأول: الرقم اللى فى بداية اسم الملف نفسه (قبل الـ underscore)
  مثال: 026_RRggnGHx5m4.txt  ->  026
- الجزء الثانى: قيمة Title اللى جوه الملف (أول سطر) بعد إزالة أى رقم
  ترقيم موجود جوه القيمة نفسها (زى "08-" أو "26-")، وإذا مفيش رقم
  بياخد قيمة الـ Title كاملة زى ما هيا.

مثال:
  اسم الملف: 008_XiS02cy6DVc.txt
  السطر الأول: Title: C# Fundamentals: 08- String Data Type (Part 1)
  الاسم النهائى: 008 - String Data Type (Part 1).txt

طريقة التشغيل:
  1. حط السكريبت جوه نفس المجلد اللى فيه ملفات الـ txt
  2. افتح Terminal / CMD جوه المجلد ده
  3. شغّل: python rename_by_title.py
     (فيه وضع تجربة قبل التنفيذ الفعلى - اتبع التعليمات اللى هتظهر)
"""

import os
import re
import sys

# نمط الرقم اللى فى بداية اسم الملف: 026_RRggnGHx5m4.txt -> 026
OUTER_NUM_PATTERN = re.compile(r'^(\d+)_')

# نمط الرقم جوه قيمة الـ title، زى "08-" أو "26-" أو "059-"
INNER_NUM_PATTERN = re.compile(r'\d+\s*-\s*(.+)$')

# أحرف ممنوعة فى أسماء الملفات على ويندوز
ILLEGAL_CHARS = r'<>:"/\|?*'


def sanitize(name: str) -> str:
    # استبدال الأحرف الممنوعة برمز مقروء بدل الحذف عشان الكلمات متلزقش ببعض
    name = name.replace(':', ' -')
    name = name.replace('/', '-')
    name = name.replace('\\', '-')
    for ch in '<>"|?*':
        name = name.replace(ch, '')
    name = re.sub(r'\s+', ' ', name).strip()
    name = name.rstrip('.')  # ويندوز مش بيحب النقطة فى الآخر
    return name


def extract_title(first_line: str) -> str:
    """يشيل كلمة Title: من بداية السطر ويرجع القيمة بعدها"""
    line = first_line.strip()
    if line.lower().startswith('title:'):
        line = line[len('title:'):].strip()
    return line


def build_new_name(filename: str, title_value: str) -> str:
    outer_match = OUTER_NUM_PATTERN.match(filename)
    outer_num = outer_match.group(1) if outer_match else None

    inner_match = INNER_NUM_PATTERN.search(title_value)
    if inner_match:
        inner_text = inner_match.group(1).strip()
    else:
        inner_text = title_value.strip()

    if outer_num:
        new_base = f"{outer_num} - {inner_text}"
    else:
        new_base = inner_text

    return sanitize(new_base) + ".txt"


def main():
    folder = os.path.dirname(os.path.abspath(__file__))
    files = [f for f in os.listdir(folder) if f.lower().endswith('.txt')]
    files.sort()

    if not files:
        print("مفيش ملفات .txt فى المجلد ده.")
        return

    plan = []  # (old_name, new_name)
    skipped = []

    for filename in files:
        full_path = os.path.join(folder, filename)
        try:
            with open(full_path, 'r', encoding='utf-8', errors='ignore') as fh:
                first_line = fh.readline()
        except Exception as e:
            skipped.append((filename, f"خطأ فى القراءة: {e}"))
            continue

        if not first_line.strip().lower().startswith('title:'):
            skipped.append((filename, "مفيش سطر Title فى أول سطر"))
            continue

        title_value = extract_title(first_line)
        new_name = build_new_name(filename, title_value)

        if not new_name or new_name == ".txt":
            skipped.append((filename, "الاسم الناتج فاضى"))
            continue

        plan.append((filename, new_name))

    # حل تعارض الأسماء المتكررة
    seen = {}
    final_plan = []
    for old_name, new_name in plan:
        base, ext = os.path.splitext(new_name)
        count = seen.get(new_name, 0)
        if count == 0:
            seen[new_name] = 1
            final_plan.append((old_name, new_name))
        else:
            seen[new_name] += 1
            alt_name = f"{base} ({count}){ext}"
            final_plan.append((old_name, alt_name))

    print("=" * 60)
    print("خطة إعادة التسمية:")
    print("=" * 60)
    for old_name, new_name in final_plan:
        print(f"  {old_name}\n  ->  {new_name}\n")

    if skipped:
        print("-" * 60)
        print("ملفات اتم تجاهلها:")
        for filename, reason in skipped:
            print(f"  {filename}  ({reason})")
        print("-" * 60)

    answer = input(f"\nهيتم إعادة تسمية {len(final_plan)} ملف. اكتب 'y' للتنفيذ الفعلى، أى حاجة تانية للإلغاء: ").strip().lower()

    if answer != 'y':
        print("تم الإلغاء. مفيش ملفات اتغيرت.")
        return

    done = 0
    for old_name, new_name in final_plan:
        old_path = os.path.join(folder, old_name)
        new_path = os.path.join(folder, new_name)
        try:
            os.rename(old_path, new_path)
            done += 1
        except Exception as e:
            print(f"فشل تغيير اسم {old_name}: {e}")

    print(f"\nتم بنجاح! اتغير اسم {done} ملف.")


if __name__ == '__main__':
    main()

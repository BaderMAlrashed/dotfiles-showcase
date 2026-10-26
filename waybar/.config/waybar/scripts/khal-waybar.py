#!/usr/bin/env python3
# ~/.config/waybar/scripts/khal-waybar.py
# Waybar custom module: Hijri date + next Islamic/Saudi event
# Output: JSON {text, tooltip, class}

import json
import subprocess
from datetime import date, datetime

from hijridate import Gregorian

CALENDARS = ["islamic", "saudi"]
LOOKAHEAD_DAYS = 60

# Shorten long event names for the bar
SHORTNAMES = {
    "Fast: Day of Arafah (9 Dhul Hijjah)": "Arafah fast",
    "Ramadan": "Ramadan",
    "Eid al-Fitr": "Eid al-Fitr",
    "Eid al-Adha": "Eid al-Adha",
    "Fast: Ashura (10 Muharram)": "Ashura fast",
    "Fast: Tasu'a (9 Muharram)": "Tasu'a fast",
    "Laylat al-Qadr (27 Ramadan)": "Laylat al-Qadr",
    "Islamic New Year": "Hijri New Year",
    "Saudi National Day": "National Day",
    "Saudi Founding Day": "Founding Day",
    "Mawlid al-Nabi (12 Rabi al-Awwal)": "Mawlid",
    "Isra wal-Miraj (27 Rajab)": "Isra wal-Miraj",
}

def shorten(name):
    # Before the table: its plain "Ramadan" entry would match these too.
    if "Ramadan" in name and "begins" in name:
        return "Ramadan begins"
    if "Ramadan" in name and "full month" in name:
        return None  # skip the span event, show the "begins" one
    for k, v in SHORTNAMES.items():
        if k.lower() in name.lower():
            return v
    # Trim "White Day fast - ..." to just "White Day fast"
    if "White Day fast" in name:
        return "White Day fast"
    if "Recommended fast" in name:
        return "Arafah fast" if "Dhul Hijjah" in name else "Recommended fast"
    if "Dhul Hijjah - first 10" in name:
        return "First 10 Dhul Hijjah"
    if "Hajj:" in name:
        return name.replace("Hajj: ", "")
    if "earnings season" in name:
        return name.replace("Tadawul ", "")
    return name[:28] + "…" if len(name) > 28 else name

def get_hijri():
    today = date.today()
    h = Gregorian(today.year, today.month, today.day).to_hijri()
    return f"{h.day} {h.month_name('en')} {h.year}"

# khal prints {start-date} in its configured `dateformat`; ISO and the
# day-first format used in this setup's khal config are both accepted.
DATE_FORMATS = ["%Y-%m-%d", "%d/%m/%Y"]

def parse_date(s):
    for fmt in DATE_FORMATS:
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            pass
    return None

def get_events():
    today = date.today()

    args = ["khal", "list",
            "--include-calendar", "islamic",
            "--include-calendar", "saudi",
            "--format", "{title}|||{start-date}",
            "today", f"{LOOKAHEAD_DAYS}d"]
    try:
        out = subprocess.check_output(args, stderr=subprocess.DEVNULL, text=True)
    except (subprocess.CalledProcessError, OSError):  # khal failed or missing
        return []

    events = []
    for line in out.splitlines():
        line = line.strip()
        if not line or "|||" not in line:
            continue
        parts = line.split("|||")
        if len(parts) < 2:
            continue
        title = parts[0].strip()
        date_str = parts[1].strip()
        short = shorten(title)
        if short is None:
            continue
        d = parse_date(date_str)
        if d is None:
            continue
        days_away = (d - today).days
        events.append((days_away, short, title, d))

    events.sort(key=lambda x: (x[0], x[1]))
    return events

def main():
    hijri = get_hijri()
    events = get_events()

    # Bar text: Hijri date + next event
    if events:
        days_away, short, full, edate = events[0]
        if days_away == 0:
            next_str = f"  {short}"
            css_class = "event-today"
        elif days_away == 1:
            next_str = f"  {short} · tmrw"
            css_class = "event-soon"
        else:
            next_str = f"  {short} · {days_away}d"
            css_class = "event-upcoming"
    else:
        next_str = ""
        css_class = "normal"

    text = f"🌙 {hijri}{next_str}"

    # Tooltip: next 8 events
    tooltip_lines = [f"<b>{hijri}</b>", ""]
    seen = set()
    count = 0
    for days_away, short, full, edate in events:
        key = (edate, short)
        if key in seen:
            continue
        seen.add(key)
        if count >= 8:
            break
        datestr = edate.strftime("%a %d %b")
        if days_away == 0:
            prefix = "● Today   "
        elif days_away == 1:
            prefix = "● Tomorrow"
        else:
            prefix = f"  {datestr}"
        tooltip_lines.append(f"{prefix}  {full}")
        count += 1

    tooltip = "\n".join(tooltip_lines)

    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": css_class
    }))

if __name__ == "__main__":
    main()

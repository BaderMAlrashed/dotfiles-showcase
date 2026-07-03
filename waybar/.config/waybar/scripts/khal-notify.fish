#!/usr/bin/env fish
# ~/.config/waybar/scripts/khal-notify.fish
# Send a mako notification with today's Islamic/Saudi events
# Run via systemd timer at startup and daily at 07:00

set today (date +"%d/%m/%Y")
set hijri (python3 -c "
from hijridate import Gregorian
from datetime import date
t = date.today()
h = Gregorian(t.year, t.month, t.day).to_hijri()
print(f'{h.day} {h.month_name(\"en\")} {h.year} AH')
")

# Get today's events
set today_events (khal list \
    --include-calendar islamic \
    --include-calendar saudi \
    --format "{title}" \
    today 1d 2>/dev/null | string trim | grep -v '^$')

# Get next 3 days events (excluding today)
set upcoming_events (khal list \
    --include-calendar islamic \
    --include-calendar saudi \
    --format "{start-date} {title}" \
    tomorrow 3d 2>/dev/null | string trim | grep -v '^$')

# Build notification body
set body ""

if test (count $today_events) -gt 0
    set body $body"<b>Today</b>\n"
    for ev in $today_events
        set body $body"• $ev\n"
    end
else
    set body $body"<i>No Islamic events today</i>\n"
end

if test (count $upcoming_events) -gt 0
    set body $body"\n<b>Coming up</b>\n"
    # Show up to 5 upcoming
    set count 0
    for ev in $upcoming_events
        if test $count -ge 5
            break
        end
        set body $body"• $ev\n"
        set count (math $count + 1)
    end
end

notify-send \
    --app-name="khal" \
    --urgency=low \
    --expire-time=10000 \
    --icon=x-office-calendar \
    "🌙 $hijri" \
    $body

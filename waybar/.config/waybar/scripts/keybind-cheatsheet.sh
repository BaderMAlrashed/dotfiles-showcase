#!/usr/bin/env bash
# Toggleable cheatsheet of the Hyprland keybinds that are easy to forget.
# Deliberately curated, not auto-parsed from keybinds.conf: muscle-memory
# binds (movefocus, workspace switching, kill/exit, basic launchers) are
# left out on purpose — this is a reminder list, not a full reference.
set -euo pipefail

if pkill -x fuzzel 2>/dev/null; then
    exit 0
fi

CHEATSHEET="
SUPER + /                 Show this keybind cheatsheet
SUPER + E                 Godot scratchpad terminal
SUPER SHIFT + Return      Foot session picker
SUPER + C                 Calcurse (calendar)
SUPER ALT + L             Lock screen
SUPER + L                 Quick capture inbox
SUPER + P                 Pseudo tiling
SUPER + V                 Toggle split layout
Print                     Screenshot: full screen -> save
CTRL + Print              Screenshot: full screen -> clipboard
SHIFT + Print             Screenshot: region -> save
CTRL SHIFT + Print        Screenshot: region -> clipboard
ALT + Print               Screenshot: active window -> save
SUPER + Print             Screenshot: region -> annotate (swappy)
SUPER + R                 Record: toggle full screen
SUPER SHIFT + R           Record: toggle region
SUPER ALT + R             Record: toggle with mic
SUPER + N                 Notification / control center
SUPER SHIFT + N           Dismiss all notifications
F7 (XF86Display)          Swap external display / projector
F8 (XF86RFKill)           Toggle airplane mode
F12 (XF86Favorites)       Open nmtui (network manager)
XF86KbdBrightness +/-     Keyboard backlight
"

echo "$CHEATSHEET" | sed '/^\s*$/d' \
    | fuzzel --dmenu --prompt "Keybinds  " --lines 25 --width 90 --no-icons >/dev/null

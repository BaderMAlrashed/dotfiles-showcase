#!/usr/bin/env bash
# Regenerates config.json from config.json.tmpl with fresh system stats,
# update/dotfiles counts, and mic-mute state, then opens the panel.
# Bound to the control-center keybinds/click instead of a bare
# `swaync-client --toggle-panel` so the numbers are current on every open.
set -euo pipefail

# The panel is already open -> this invocation is a close, skip regeneration
# entirely so closing is instant instead of paying the checkupdates cost below.
if [ "${1:-}" != "--no-toggle" ] && hyprctl layers 2>/dev/null | grep -q swaync-control-center; then
  swaync-client --close-panel
  exit 0
fi

DOTFILES="$HOME/.dotfiles"
TMPL="$DOTFILES/swaync/.config/swaync/config.json.tmpl"
OUT="$HOME/.config/swaync/config.json"
UPDATES_CACHE="$HOME/.cache/swaync-updates-count"

# CPU usage (%)
cpu=$(top -bn1 | awk -F'[, ]+' '/Cpu\(s\)/{printf "%.0f", 100-$8}')

# Memory used/total
read -r mem_used mem_total <<< "$(free -h | awk '/^Mem:/{print $3, $2}')"

# CPU package temperature
temp_c="?"
for z in /sys/class/thermal/thermal_zone*; do
  if [ "$(cat "$z/type" 2>/dev/null)" = "x86_pkg_temp" ]; then
    temp_c=$(( $(cat "$z/temp") / 1000 ))
    break
  fi
done

sys_stats="CPU ${cpu}%   MEM ${mem_used}/${mem_total}   TEMP ${temp_c}°C"

# Pending package updates: read last cached count instantly, refresh the
# cache in the background (checkupdates itself takes ~1s, too slow to block on).
# checkupdates exits 0 = updates listed, 2 = none, anything else = failed
# (offline, lock held). On failure the old cache is kept, never replaced by 0.
updates_count=$(cat "$UPDATES_CACHE" 2>/dev/null || true)
setsid bash -c '
  list=$(checkupdates 2>/dev/null); rc=$?
  case $rc in
    0) printf "%s\n" "$list" | grep -c . > "$1.tmp" ;;
    2) echo 0 > "$1.tmp" ;;
    *) exit 0 ;;
  esac
  mv -f "$1.tmp" "$1"
' _ "$UPDATES_CACHE" </dev/null >/dev/null 2>&1 &
disown
if ! [[ "$updates_count" =~ ^[0-9]+$ ]]; then
  updates_label="Updates unknown"
elif [ "$updates_count" -eq 0 ]; then
  updates_label="Up to date"
else
  updates_label="${updates_count} pending"
fi

# Dotfiles changes
dotfiles_count=$(cd "$DOTFILES" && git status --porcelain | wc -l)
if [ "$dotfiles_count" -eq 0 ]; then
  dotfiles_label="Dotfiles clean"
else
  dotfiles_label="${dotfiles_count} to sync"
fi

# Mic mute state -> matching icon
if pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q yes; then
  mic_icon=$'\U000f036d'
else
  mic_icon=$'\U000f036c'
fi

export sys_stats updates_label dotfiles_label mic_icon

# Render to a temp file and rename, so swaync never reads a half-written config.
envsubst < "$TMPL" > "$OUT.tmp"
mv -f "$OUT.tmp" "$OUT"

if [ "${1:-}" = "--no-toggle" ]; then
  swaync-client --reload-config >/dev/null 2>&1 || true
  exit 0
fi

swaync-client --reload-config >/dev/null 2>&1
swaync-client --toggle-panel

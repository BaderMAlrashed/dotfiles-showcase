# dotfiles-showcase

A curated snapshot of my Arch Linux + Hyprland desktop setup — the visual and
workflow layer (window manager, bar, launcher, notifications, terminal).
This is a presentational copy, not a live-linked config; see "About this repo"
below for why.

## What's here

| Package    | What it configures                                     |
|------------|---------------------------------------------------------|
| `hyprland` | Window manager: keybinds, window rules, input, monitors |
| `waybar`   | Status bar, including a custom Hijri calendar module    |
| `rofi`     | Quick-capture menu (dmenu-style, not the app launcher — that's `fuzzel`) |
| `mako`     | Notification daemon styling                             |
| `foot`     | Terminal emulator config                                |

Managed with [GNU Stow](https://www.gnu.org/software/stow/) — each folder
mirrors its target path under `$HOME`.

## Notable features

- **Bilingual EN/AR desktop**: native XKB keyboard layout switching
  (`us,ara` via `alt+shift`), full Arabic font stack (Noto Sans/Kufi Arabic),
  and `ar_SA` locale — not a bolt-on input method, configured at the window
  manager/XKB level.
- **Hijri calendar integration**: a custom waybar module (`khal-waybar.py`)
  converts the Gregorian date to Hijri via `hijridate` and cross-references
  `khal`-managed Islamic/Saudi calendars for upcoming religious and national
  observances, shown directly in the bar.
- **Quick-capture workflow**: a rofi-driven script (in the private/full
  dotfiles, not included here) for logging notes/ideas/media without
  breaking flow, tagged with the active window's context.

## About this repo

This is deliberately a **snapshot**, not the live config — my actual
dotfiles are stowed directly into `$HOME` from a private repo (so editing
`~/.config/hypr/...` is editing the repo directly). This public copy exists
to show the interesting parts without exposing machine-specific details
(local network addresses, personal scripts, systemd units tied to this one
machine). I refresh it manually when there's something worth sharing.

## How this was built

I'm learning Arch Linux and Hyprland hands-on, and used Claude (Anthropic)
heavily throughout — as a pair-programming partner for writing Hyprland/waybar
configs, debugging systemd units, and understanding *why* a given approach
works, not just copy-pasting a finished config. I'm not going to pretend this
was all typed from a blank terminal; the value I'm demonstrating here is
being able to direct an AI tool effectively toward a working, personalized,
non-trivial system, and to understand and maintain the result afterward.

## License

Feel free to take anything useful from here for your own setup.

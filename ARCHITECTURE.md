# dotfiles-showcase — architecture

A public, hand-refreshed copy of part of a private dotfiles repo
(`~/.dotfiles`, GNU Stow). Nothing here is generated or installed by a script.

## Layout

- One folder per Stow package (`hyprland`, `waybar`, `rofi`, `swaync`,
  `foot`); each mirrors its target path under `$HOME`.
- `tests/` is not a package: it holds the unit tests (below).
- Records: `PROJECT.md` (state), `TASKS.md` (open work). `devlog/` is local only
  (gitignored).

## Moving parts

- **Hijri bar module** — `waybar/.../scripts/khal-waybar.py`, run by the
  waybar `custom/khal` module. Converts today to Hijri (`hijridate`) and lists
  the next 60 days from the khal calendars in `CALENDARS`. khal prints dates in
  its own configured `dateformat`; `parse_date` accepts ISO and `%d/%m/%Y`.
  `khal-notify.fish` sends the same events as a notification.
- **Control center** — `swaync/.../scripts/refresh-panel.sh` renders
  `config.json.tmpl` with `envsubst` (CPU/RAM/temp, pending updates, dotfiles
  status, mic state), writes via temp + rename, then toggles the panel. The
  update count is cached and refreshed in the background.
- **Helpers behind panel buttons** — `sys-update.sh` (`sudo pacman -Syu`) and
  `dotfiles-sync.sh` (stages tracked changes only; new files need a yes).

## Tests

`python3 -m unittest discover -s tests` (needs `hijridate`). 7 tests in
`tests/test_khal_waybar.py`: date parsing (ISO, day-first, junk), khal missing,
calendar args, name shortening. Shell, fish and config files have no tests;
`shellcheck` and `ruff check` are clean as of 2026-10-26.

## Latent issues (audit 2026-10-26)

- `refresh-panel.sh` and `dotfiles-sync.sh` hard-code `~/.dotfiles`; on any
  other machine the panel script exits at `envsubst` (missing template).
- `keybind-cheatsheet.sh` ships under `waybar/.../scripts/`, but both callers
  (`keybinds.conf:24`, waybar `config:120`) run `~/.local/bin/keybind-cheatsheet.sh`.
- Volume and brightness keys are bound twice in `keybinds.conf` (96-99 and
  109-117).
- The snapshot is behind the live config: live Hyprland is now Lua
  (`hyprland.lua`), so every `.conf` under `hyprland/.config/hypr/configs/` is
  obsolete.

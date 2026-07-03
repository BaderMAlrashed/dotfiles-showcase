#!/usr/bin/env bash

# Use nala, pacman, or yay/paru depending on your preference.
# Since you're on Arch, we'll use a standard pacman + AUR helper approach.

echo "--- Starting System Update ---"
sudo pacman -Syu

# If you use an AUR helper like yay or paru, uncomment the next line:
# yay -Sua

echo "--- Update Complete ---"
echo "Refreshing Waybar..."

# Send signal 8 to Waybar to refresh the custom/updates module
pkill -RTMIN+8 waybar

# Keep the terminal open for a second so you can see the result
sleep 2

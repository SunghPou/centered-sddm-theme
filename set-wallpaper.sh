#!/bin/sh
# Copy the current wallpaper to a location the SDDM greeter can read.
# Usage: set-wallpaper.sh /path/to/image
set -e
install -m 644 "$1" /tmp/sddm-wallpaper

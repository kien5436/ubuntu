#!/bin/bash

set -euo pipefail

BACKUP_DIR="$(pwd)/preferences/"
rm -rf "$BACKUP_DIR" && mkdir -p "$BACKUP_DIR"
echo "?? Saving configuration to: $BACKUP_DIR"

# 3. Backup Homebrew packages
echo "🍺 Dumping Brewfile..."
brew bundle dump --file="$BACKUP_DIR/Brewfile" --describe --force

# 4. (Optional) List services
echo "🔁 Backing up brew services list..."
brew services list > "$BACKUP_DIR/brew-services.txt"

dpkg --get-selections > "$BACKUP_DIR/apt-packages.txt"
sudo cp -R /etc/apt/sources.list* "$BACKUP_DIR"
comm -23 \
  <(apt-mark showmanual | sort) \
  <(gzip -dc /var/log/installer/initial-status.gz | sed 's/^Package: //p;d' | sort) \
  > "$BACKUP_DIR/manual-packages.txt"

echo "Backup complete"

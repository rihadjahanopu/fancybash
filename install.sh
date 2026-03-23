#!/bin/bash

BASHRC="$HOME/.bashrc"
URL="https://gist.githubusercontent.com/rihadjahanopu/a1c286e48b3ecee1a207c759279e352c/raw/config.sh"

START="# >>> opu-bashrc >>>"
END="# <<< opu-bashrc <<<"

# 🔍 check already installed
if grep -q "$START" "$BASHRC"; then
    echo "✅ Already installed! Nothing to do."
    exit 0
fi

echo "Installing..."

# 📥 add config block
{
  echo "$START"
  curl -fsSL "$URL"
  echo "$END"
} >> "$BASHRC"

# 🔄 reload
source "$BASHRC"

echo "✅ Installed successfully!"
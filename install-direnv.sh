#!/usr/bin/env bash

# Function to detect shell type
detect_shell() {
  case "$SHELL" in
    */bash) echo "bash" ;;
    */zsh) echo "zsh" ;;
    *) echo "unknown" ;;
  esac
}

SHELL_TYPE=$(detect_shell)

if [ "$SHELL_TYPE" = "unknown" ]; then
  echo "❌ Could not detect shell type."
  exit 1
fi

echo "🐚 Detected shell: $SHELL_TYPE"

# Install direnv
echo "📦 Installing direnv..."
curl -sfL https://direnv.net/sHELL  | bash

if ! command -v direnv &> /dev/null; then
  echo "❌ Failed to install direnv"
  exit 1
fi

echo "✅ direnv installed successfully."

# Add direnv hook to shell profile
PROFILE_FILE="$HOME/.${SHELL_TYPE}rc"

echo "🔧 Adding direnv hook to $PROFILE_FILE..."

cat >> "$PROFILE_FILE" <<EOL

# direnv initialization
eval "\$(direnv hook $SHELL_TYPE)"
EOL

source "$PROFILE_FILE"

echo "✅ direnv hook added to $PROFILE_FILE and sourced."
echo "🎉 direnv is now set up for $SHELL_TYPE"
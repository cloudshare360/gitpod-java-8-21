tasks:
  - name: Setup direnv
    init: |
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


  # --- Task: List Installed Java Versions ---
  - name: List Installed Java Versions
    init: |
      echo "🔍 Checking for installed Java versions via SDKMAN..."

      # Load SDKMAN if not already loaded
      if [ -d "$HOME/.sdkman" ]; then
        export SDKMAN_DIR="$HOME/.sdkman"
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
      else
        echo "❌ SDKMAN not found. Please install SDKMAN first."
        exit 1
      fi

      # List only installed Java versions
      sdk list java | grep 'installed'

  # --- Task: Show Current Java Environment ---
  - name: Show Current Java Environment
    init: |
      echo "🌐 Checking current Java environment..."

      # Load SDKMAN
      if [ -d "$HOME/.sdkman" ]; then
        export SDKMAN_DIR="$HOME/.sdkman"
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
      else
        echo "❌ SDKMAN not found. Please install SDKMAN first."
        exit 1
      fi

      # Get current/default Java version
      CURRENT_JAVA=$(sdk current java 2>/dev/null)

      if [[ "$CURRENT_JAVA" == *"No version set"* ]]; then
        echo "⚠️ No Java version is currently set via SDKMAN."
      else
        echo "✅ Current Java version:"
        echo "$CURRENT_JAVA"
        java -version
      fi
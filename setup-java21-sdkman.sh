#!/usr/bin/env bash

# ============ Helper Functions ============
function detect_shell() {
    # Returns "bash" or "zsh"
    local SHELL_NAME=$(basename "$SHELL")
    echo "$SHELL_NAME"
}

function source_sdkman_in_shell_profile() {
    local SHELL_TYPE=$1
    local PROFILE_FILE="$HOME/.${SHELL_TYPE}rc"

    echo "Updating $PROFILE_FILE to include SDKMAN initialization..."

    cat >> "$PROFILE_FILE" <<EOL

# SDKMAN initialization
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOL

    echo "✅ SDKMAN added to $PROFILE_FILE"
}

# ============ Main Script ============

echo "🔍 Checking for SDKMAN installation..."

if [ -d "$HOME/.sdkman" ]; then
    echo "✅ SDKMAN is already installed."
else
    echo "❌ SDKMAN not found. Installing SDKMAN..."
    
    # Download and install SDKMAN
    curl -s "https://get.sdkman.io"  | bash

    if [ $? -ne 0 ]; then
        echo "❌ Failed to install SDKMAN!"
        exit 1
    fi

    echo "✅ SDKMAN installed successfully."

    # Detect shell type and update profile
    SHELL_TYPE=$(detect_shell)
    source_sdkman_in_shell_profile "$SHELL_TYPE"

    echo "🔄 Reloading shell profile..."
    export SDKMAN_DIR="$HOME/.sdkman"
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# Now ensure sdk command is available
if ! command -v sdk &> /dev/null; then
    echo "🔄 Manually sourcing SDKMAN due to environment issues..."
    export SDKMAN_DIR="$HOME/.sdkman"
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# Check again after sourcing
if ! command -v sdk &> /dev/null; then
    echo "❌ SDKMAN is not available in this session. Please restart your terminal or source manually."
    exit 1
fi

# Install Java 21 if not present
JAVA_VERSION="21.0.6.fx-zulu"

echo "🔍 Checking for Java $JAVA_VERSION..."
if sdk list java | grep -q "$JAVA_VERSION"; then
    echo "✅ Java $JAVA_VERSION is available."
else
    echo "📥 Java $JAVA_VERSION not found. Installing..."
    yes | sdk install java "$JAVA_VERSION"
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Java $JAVA_VERSION"
        exit 1
    fi
fi

# Set Java 21 as current version
echo "🔄 Setting Java $JAVA_VERSION as current version..."
sdk use java "$JAVA_VERSION"

# Optional: Set as default version
echo "⚙️ Setting Java $JAVA_VERSION as default..."
sdk default java "$JAVA_VERSION"

# Final check
echo "✅ Java version:"
java -version
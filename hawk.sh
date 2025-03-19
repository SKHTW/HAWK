#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning for XSS
# Saves final results to a single file: Output.txt

# Configuration
CONFIG_FILE="$HOME/.hawk_config"
OUTPUT_FILE="Output.txt"
REQUIRED_TOOLS=("waybackurls" "gf" "uro" "kxss" "katana" "jq" "curl" "pv")
START_TIME=$(date +%s)
TOOL_INSTALL_PATH=""

# Load or prompt for OTX API Key and Tool Install Path
load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
  fi

  if [ -z "$OTX_API_KEY" ]; then
    echo "Enter your OTX API Key:"
    read -r OTX_API_KEY
    echo "Saving API Key..."
    echo "OTX_API_KEY=\"$OTX_API_KEY\"" > "$CONFIG_FILE"
  fi

  if [ -z "$TOOL_INSTALL_PATH" ]; then
    echo "Enter the path to install tools (e.g., /usr/local/bin):"
    read -r TOOL_INSTALL_PATH
    echo "Saving Tool Install Path..."
    echo "TOOL_INSTALL_PATH=\"$TOOL_INSTALL_PATH\"" >> "$CONFIG_FILE"
  fi
}

# Function to check and install missing tools
check_tools() {
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "[*] $tool not found. Installing..."
      case $tool in
        "waybackurls"|"gf"|"kxss")
          GO111MODULE=on go install -v github.com/tomnomnom/$tool@latest
          if [ $? -eq 0 ]; then
            mv "$HOME/go/bin/$tool" "$TOOL_INSTALL_PATH/$tool"
          else
            echo "[!] Failed to install $tool. Exiting."
            exit 1
          fi
          ;;
        "katana")
          GO111MODULE=on go install github.com/projectdiscovery/katana/cmd/katana@latest
          if [ $? -eq 0 ]; then
            mv "$HOME/go/bin/katana" "$TOOL_INSTALL_PATH/katana"
          else
            echo "[!] Failed to install katana. Exiting."
            exit 1
          fi
          ;;
        "uro")
          pip install uro
          if [ $? -ne 0 ]; then
            echo "[!] Failed to install uro. Exiting."
            exit 1
          fi
          ;;
        "jq")
          sudo apt-get update && sudo apt-get install -y jq
          if [ $? -ne 0 ]; then
            echo "[!] Failed to install jq. Exiting."
            exit 1
          fi
          ;;
        "curl")
          sudo apt-get update && sudo apt-get install -y curl
          if [ $? -ne 0 ]; then
            echo "[!] Failed to install curl. Exiting."
            exit 1
          fi
          ;;
        "pv")
          sudo apt-get update && sudo apt-get install -y pv
          if [ $? -ne 0 ]; then
            echo "[!] Failed to install pv. Exiting."
            exit 1
          fi
          ;;
      esac
      echo "[*] $tool installed successfully."
    else
      echo "[*] $tool is already installed."
    fi
  done
}

# Add HAWK to PATH for global use
add_to_path() {
  SCRIPT_PATH=$(realpath "$0")
  SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
  if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
    echo "export PATH=\"\$PATH:$SCRIPT_DIR\"" >> "$HOME/.bashrc"
    export PATH="$PATH:$SCRIPT_DIR"
    echo "[*] HAWK added to PATH. Restart your terminal to apply changes."
  fi
}

# Display help message
show_help() {
  echo "Usage: hawk <target-domain> [options]"
  echo ""
  echo "Options:"
  echo "  -h          Show this help message."
  echo "  -update     Update HAWK to the latest version."
  echo ""
  echo "Note: Scans may consume significant disk space and take a long time to complete."
}

# Update the script
update_hawk() {
  SCRIPT_URL="https://raw.githubusercontent.com/yourusername/HAWK/main/hawk.sh"
  curl -sL "$SCRIPT_URL" -o "$(which hawk)" && chmod +x "$(which hawk)"
  if [ $? -ne 0 ]; then
    echo "[!] Failed to update HAWK."
  else
    echo "HAWK updated to the latest version."
  fi

}

# Parse flags and options
if [[ "$1" == "-h" ]]; then
  show_help
  exit 0
elif [[ "$1" == "-update" ]]; then
  update_hawk
  exit 0
fi

# Check if a target domain is provided
if [ -z "$1" ]; then
  echo "Usage: hawk <target-domain>"
  exit 1
fi

TARGET="$1"
echo "[*] Starting HAWK for $TARGET"
echo "[*] Results will be saved to $OUTPUT_FILE"

# Load config and install tools
load_config
check_tools
add_to_path

# Ensure the output file is empty
> "$OUTPUT_FILE"

# Step 1: Gather URLs
echo "[*] Gathering URLs..."

echo "  [+] From Wayback Machine..."
echo "$TARGET" | waybackurls | pv -l > >(tee -a "$OUTPUT_FILE")

echo "  [+] From OTX..."
curl -s -H "X-OTX-API-KEY: $OTX_API_KEY" \
  "https://otx.alienvault.com/api/v1/indicators/domain/$TARGET/url_list" \
  | jq -r '.url_list[].url' | pv -l > >(tee -a "$OUTPUT_FILE")

echo "  [+] From Katana..."
katana -u "$TARGET" -d 3 -jc -silent | pv -l > >(tee -a "$OUTPUT_FILE")

# Step 2: Filter URLs with gf xss
echo "[*] Filtering for potential XSS patterns with gf..."
cat "$OUTPUT_FILE" | sort -u | gf xss | pv -l > >(tee -a "$OUTPUT_FILE")

# Step 3: Clean URLs with uro
echo "[*] Cleaning and deduplicating URLs with uro..."
cat "$OUTPUT_FILE" | sort -u | uro | pv -l > >(tee -a "$OUTPUT_FILE")

# Step 4: Test with kxss
echo "[*] Testing for XSS vulnerabilities with kxss..."
cat "$OUTPUT_FILE" | sort -u | kxss >> "$OUTPUT_FILE"

# Display runtime
END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))
echo "[*] HAWK completed in $RUNTIME seconds. Final results saved in $OUTPUT_FILE"

# Auto Update Check
update_hawk

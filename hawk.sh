#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning for XSS
# Saves final results to a single file: Output.txt

# Configuration
CONFIG_FILE="<span class="math-inline">HOME/\.hawk\_config"
OUTPUT\_FILE\="Output\.txt"
REQUIRED\_TOOLS\=\("waybackurls" "gf" "uro" "kxss" "katana" "jq" "curl" "pv"\)
START\_TIME\=</span>(date +%s)
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
    echo "TOOL_INSTALL_PATH=\"$TOOL_INSTALL_PATH\"" > "<span class="math-inline">CONFIG\_FILE"
fi
\}
\# Function to check and install missing tools
check\_tools\(\) \{
for tool in "</span>{REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "[*] $tool not found. Installing..."
      case $tool in
        "waybackurls")
          GO111MODULE=on go install github.com/tomnomnom/waybackurls@latest
          if [ $? -eq 0 ]; then
            if [[ -d "$TOOL_INSTALL_PATH" && -w "$TOOL_INSTALL_PATH" ]]; then
              mv "$HOME/go/bin/waybackurls" "$TOOL_INSTALL_PATH/waybackurls"
            else
              echo "[!] Invalid tool installation path: $TOOL_INSTALL_PATH. Exiting."
              exit 1
            fi
          else
            echo "[!] Failed to install waybackurls. Exiting."
            exit 1
          fi
          ;;
        "gf"|"kxss")
          GO111MODULE=on go install github.com/Emoe/kxss@latest
          if [[ "$tool" == "gf" ]]; then
            GO111MODULE=on go install github.com/tomnomnom/gf@latest
          fi
          if [ $? -eq 0 ]; then
            if [[ -d "$TOOL_INSTALL_PATH" && -w "$TOOL_INSTALL_PATH" ]]; then
              mv "$HOME/go/bin/$tool" "$TOOL_INSTALL_PATH/$tool"
            else
              echo "[!] Invalid tool installation path: $TOOL_INSTALL_PATH. Exiting."
              exit 1
            fi
          else
            echo "[!] Failed to install $tool. Exiting."
            exit 1
          fi
          ;;
        "katana")
          GO111MODULE=on go install github.com/projectdiscovery/katana/cmd/katana@latest
          if [ $? -eq 0 ]; then
            if [[ -d "$TOOL_INSTALL_PATH" && -w "$TOOL_INSTALL_PATH" ]]; then
              mv "$HOME/go/bin/katana" "$TOOL_INSTALL_PATH/katana"
            else
              echo "[!] Invalid tool installation path: $TOOL_INSTALL_PATH. Exiting."
              exit 1
            fi
          else
            echo "[!] Failed to install katana. Exiting."
            exit 1
          fi
          ;;
        "uro")
          pipx install uro
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
      echo "[*] <span class="math-inline">tool is already installed\."
fi
done
\}
\# Add HAWK to PATH for global use
add\_to\_path\(\) \{
SCRIPT\_PATH\=</span>(realpath "<span class="math-inline">0"\)
SCRIPT\_DIR\=</span>(dirname "$SCRIPT_PATH")
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
  echo "  -config     Edit configuration settings."
  echo ""
  echo "Note: Scans may consume significant disk space and take a long time to complete."
}

# Update the script
update_hawk() {
  SCRIPT_URL="https://raw.githubusercontent.com/SKHTW/HAWK/main/hawk.sh"
  curl -sL "<span class="math-inline">SCRIPT\_URL" \-o "</span>(which hawk)" && chmod +x "$(which hawk)"
  if [ $? -ne 0 ]; then
    echo "[!] Failed to update HAWK."
  else
    echo "HAWK updated to the latest version."
  fi
}

# Configure settings
configure_settings() {
  echo "Current OTX API Key: $OTX_API_KEY"
  read -p "Enter new OTX API Key (leave blank to keep current): " NEW_OTX_API_KEY
  if [[ -n "$NEW_OTX_API_KEY" ]]; then
    OTX_API_KEY="$NEW_OTX_API_KEY"
    echo "OTX_API_KEY=\"$OTX_API_KEY\"" > "$CONFIG_FILE"
  fi

  echo "Current Tool Installation Path: $TOOL_INSTALL_PATH"
  read -p "Enter new Tool Installation Path (leave blank to keep current): " NEW_TOOL_INSTALL_PATH
  if [[ -n "$NEW_TOOL_INSTALL_PATH" ]]; then
    TOOL_INSTALL_PATH="$NEW_TOOL_INSTALL_PATH"
    echo "TOOL_INSTALL_PATH=\"$TOOL_INSTALL_PATH\"" > "$CONFIG_FILE"
  fi
}

# Parse flags and options
if [[ "$1" == "-h" ]]; then
  show_help
  exit 0
elif [[ "$1" == "-update" ]]; then
  update_hawk
  exit 0
elif [[ "$1" == "-config" ]]; then
  configure_settings
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

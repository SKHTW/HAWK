#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning for XSS
# Saves final results to a single file: Output.txt

# Configuration
CONFIG_FILE="$HOME/.hawk_config"
OUTPUT_FILE="Output.txt"
REQUIRED_TOOLS=("waybackurls" "gf" "uro" "Gxss" "kxss" "katana")
START_TIME=$(date +%s)

# Load or prompt for OTX API Key
load_api_key() {
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
  fi

  if [ -z "$OTX_API_KEY" ]; then
    echo "Enter your OTX API Key:"
    read -r OTX_API_KEY
    echo "Saving API Key..."
    echo "OTX_API_KEY=\"$OTX_API_KEY\"" > "$CONFIG_FILE"
  fi
}

# Function to check and install missing tools
check_tools() {
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "[*] $tool not found. Installing..."
      case $tool in
        "waybackurls"|"gf"|"Gxss"|"kxss")
          go install github.com/tomnomnom/$tool@latest
          ;;
        "katana")
          go install github.com/projectdiscovery/katana/cmd/katana@latest
          ;;
        "uro")
          pip install uro
          ;;
      esac
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
  echo "  -h           Show this help message."
  echo "  -update      Update HAWK to the latest version."
  echo ""
  echo "Note: Scans may consume significant disk space and take a long time to complete."
}

# Update the script
update_hawk() {
  SCRIPT_URL="https://raw.githubusercontent.com/yourusername/HAWK/main/hawk.sh"
  curl -sL "$SCRIPT_URL" -o "$(which hawk)" && chmod +x "$(which hawk)"
  echo "HAWK updated to the latest version."
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

# Run tool checks and add to PATH
check_tools
add_to_path

# Load API key
load_api_key

# Ensure the output file is empty
> $OUTPUT_FILE

# Create temporary files
TEMP_WAYBACK=$(mktemp)
TEMP_OTX=$(mktemp)
TEMP_KATANA=$(mktemp)
TEMP_GF=$(mktemp)
TEMP_URO=$(mktemp)
TEMP_GXSS=$(mktemp)
TEMP_KXSS=$(mktemp)

# Step 1: Gather URLs
echo "[*] Gathering URLs..."
echo "  [+] From Wayback Machine..."
echo "$TARGET" | waybackurls > $TEMP_WAYBACK

echo "  [+] From OTX..."
curl -s -H "X-OTX-API-KEY: $OTX_API_KEY" \
"https://otx.alienvault.com/api/v1/indicators/domain/$TARGET/url_list" \
| jq -r '.url_list[].url' > $TEMP_OTX

echo "  [+] From Katana..."
katana -u "$TARGET" -d 3 -jc -silent | tee $TEMP_KATANA

# Combine and deduplicate URLs
echo "[*] Combining and deduplicating URLs..."
cat $TEMP_WAYBACK $TEMP_OTX $TEMP_KATANA | sort -u > $TEMP_GF
rm -f $TEMP_WAYBACK $TEMP_OTX $TEMP_KATANA

# Step 2: Filter URLs with gf xss
echo "[*] Filtering for potential XSS patterns with gf..."
cat $TEMP_GF | gf xss | tee $TEMP_URO
rm -f $TEMP_GF

# Step 3: Clean URLs with uro
echo "[*] Cleaning and deduplicating URLs with uro..."
cat $TEMP_URO | uro | tee $TEMP_GXSS
rm -f $TEMP_URO

# Step 4: Test with Gxss
echo "[*] Testing for reflected parameters with Gxss..."
cat $TEMP_GXSS | Gxss | tee $TEMP_KXSS
rm -f $TEMP_GXSS

# Step 5: Test with kxss
echo "[*] Testing for XSS vulnerabilities with kxss..."
cat $TEMP_KXSS | kxss >> $OUTPUT_FILE
rm -f $TEMP_KXSS

# Display runtime
END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))
echo "[*] HAWK completed in $RUNTIME seconds. Final results saved in $OUTPUT_FILE"

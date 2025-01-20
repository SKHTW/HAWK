#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning for XSS
# Saves results to a single file: Output.txt

# Configuration
CONFIG_FILE="$HOME/.hawk_config"
OUTPUT_FILE="Output.txt"
REQUIRED_TOOLS=("waybackurls" "gf" "uro" "Gxss" "kxss" "katana")

# Function to display help
show_help() {
  echo "HAWK: Hunting Automated Workflow Kit"
  echo ""
  echo "Usage: hawk <target-domain>"
  echo ""
  echo "Example:"
  echo "  hawk example.com"
  echo ""
  echo "Note: Scans will take a long time."
}

# Automatically add HAWK to PATH
add_to_path() {
  local script_path
  script_path=$(realpath "$0")
  local target_path="/usr/local/bin/hawk"

  if [ "$script_path" != "$target_path" ]; then
    echo "[*] Adding HAWK to PATH for global use..."
    sudo cp "$script_path" "$target_path"
    sudo chmod +x "$target_path"
    echo "[+] HAWK has been added to PATH. You can now run 'hawk' from anywhere."
    exit 0
  fi
}

# Check if script is in PATH, and add it if not
if ! command -v hawk &>/dev/null; then
  add_to_path
fi

# Check for help flag
if [[ "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# Ensure a target is provided
if [ -z "$1" ]; then
  echo "Error: No target domain provided."
  show_help
  exit 1
fi

TARGET="$1"
echo "[*] Starting HAWK for $TARGET"
echo "[*] Results will be saved to $OUTPUT_FILE"

# Tool installation check
check_tools() {
  echo "[*] Checking required tools..."
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
      echo "[+] $tool installed."
    else
      echo "[*] $tool is already installed."
    fi
  done
}

# Run the tool installation check
check_tools

# Ensure the output file is empty
> $OUTPUT_FILE

# Step 1: Gather URLs
echo "[*] Gathering URLs..."
echo "## URL Gathering ##" >> $OUTPUT_FILE

# Gather URLs from Wayback Machine
echo "  [+] From Wayback Machine..."
wayback_output=$(echo "$TARGET" | waybackurls 2>/dev/null)
if [ -z "$wayback_output" ]; then
  echo "[-] No URLs found from Wayback Machine for $TARGET" >> $OUTPUT_FILE
else
  echo "$wayback_output" >> $OUTPUT_FILE
fi

# Gather URLs from OTX
echo "  [+] From OTX..." >> $OUTPUT_FILE
otx_output=$(curl -s -H "X-OTX-API-KEY: $(grep 'OTX_API_KEY' "$CONFIG_FILE" | cut -d'=' -f2)" \
  "https://otx.alienvault.com/api/v1/indicators/domain/$TARGET/url_list" \
  | jq -r '.url_list[].url' 2>/dev/null)
if [ -z "$otx_output" ]; then
  echo "[-] No URLs found from OTX for $TARGET" >> $OUTPUT_FILE
else
  echo "$otx_output" >> $OUTPUT_FILE
fi

# Gather URLs from Katana
echo "  [+] From Katana..." >> $OUTPUT_FILE
katana_output=$(katana -u "$TARGET" -d 10 -jc -silent 2>/dev/null)
if [ -z "$katana_output" ]; then
  echo "[-] No URLs found from Katana for $TARGET" >> $OUTPUT_FILE
else
  echo "$katana_output" >> $OUTPUT_FILE
fi

# Step 2: Combine and deduplicate URLs
echo "[*] Combining and deduplicating URLs..."
echo "" >> $OUTPUT_FILE
echo "## Deduplicated URLs ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | sort -u >> $OUTPUT_FILE

# Step 3: Filter URLs with gf xss
echo "[*] Filtering for potential XSS patterns with gf..."
echo "" >> $OUTPUT_FILE
echo "## GF XSS Patterns ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | gf xss >> $OUTPUT_FILE

# Step 4: Clean URLs with uro
echo "[*] Cleaning and deduplicating URLs with uro..."
echo "" >> $OUTPUT_FILE
echo "## Cleaned URLs (uro) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | uro >> $OUTPUT_FILE

# Step 5: Test with Gxss
echo "[*] Testing for reflected parameters with Gxss..."
echo "" >> $OUTPUT_FILE
echo "## Reflected Parameters (Gxss) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | Gxss >> $OUTPUT_FILE

# Step 6: Test with kxss
echo "[*] Testing for XSS vulnerabilities with kxss..."
echo "" >> $OUTPUT_FILE
echo "## Potential XSS Vulnerabilities (kxss) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | kxss >> $OUTPUT_FILE

# Completion
echo "[*] HAWK completed. Results saved in $OUTPUT_FILE"

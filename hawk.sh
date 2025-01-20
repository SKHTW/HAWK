#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning for XSS
# Saves final results to a single file: Output.txt

# Configuration
OTX_API_KEY="your-otx-api-key"
OUTPUT_FILE="Output.txt"
REQUIRED_TOOLS=("waybackurls" "gf" "uro" "Gxss" "kxss" "katana")

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

# Check and install required tools
check_tools

# Ensure the output file is empty
> $OUTPUT_FILE

# Check if a target domain is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target-domain>"
  exit 1
fi

TARGET="$1"
echo "[*] Starting HAWK for $TARGET"
echo "[*] Results will be saved to $OUTPUT_FILE"

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
katana -u "$TARGET" -d 3 -jc -silent > $TEMP_KATANA

# Combine and deduplicate URLs
echo "[*] Combining and deduplicating URLs..."
cat $TEMP_WAYBACK $TEMP_OTX $TEMP_KATANA | sort -u > $TEMP_GF
rm -f $TEMP_WAYBACK $TEMP_OTX $TEMP_KATANA  # Cleanup

# Step 2: Filter URLs with gf xss
echo "[*] Filtering for potential XSS patterns with gf..."
cat $TEMP_GF | gf xss > $TEMP_URO
rm -f $TEMP_GF  # Cleanup

# Step 3: Clean URLs with uro
echo "[*] Cleaning and deduplicating URLs with uro..."
cat $TEMP_URO | uro > $TEMP_GXSS
rm -f $TEMP_URO  # Cleanup

# Step 4: Test with Gxss
echo "[*] Testing for reflected parameters with Gxss..."
cat $TEMP_GXSS | Gxss > $TEMP_KXSS
rm -f $TEMP_GXSS  # Cleanup

# Step 5: Test with kxss
echo "[*] Testing for XSS vulnerabilities with kxss..."
cat $TEMP_KXSS | kxss >> $OUTPUT_FILE
rm -f $TEMP_KXSS  # Cleanup

# Completion
echo "[*] HAWK completed. Final results saved in $OUTPUT_FILE"

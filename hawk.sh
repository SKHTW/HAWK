#!/bin/bash

# HAWK: Hunting Automated Workflow Kit
# Automates URL discovery, crawling, and vulnerability scanning
# Consolidates all results into a single file: Output.txt

# Configuration
OTX_API_KEY="your-otx-api-key"
OUTPUT_FILE="Output.txt"

# Clear the output file before starting
> $OUTPUT_FILE

# Check if a target domain is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target-domain>"
  exit 1
fi

TARGET="$1"

echo "[*] Starting HAWK for $TARGET"
echo "[*] Results will be saved to $OUTPUT_FILE"

# Step 1: Gather URLs
echo "[*] Gathering URLs..."
echo "## URL Gathering ##" >> $OUTPUT_FILE
echo "  [+] From Wayback Machine..."
echo "$TARGET" | waybackurls >> $OUTPUT_FILE
echo "  [+] From OTX..." >> $OUTPUT_FILE
curl -s -H "X-OTX-API-KEY: $OTX_API_KEY" \
"https://otx.alienvault.com/api/v1/indicators/domain/$TARGET/url_list" \
| jq -r '.url_list[].url' >> $OUTPUT_FILE
echo "  [+] From Katana..." >> $OUTPUT_FILE
katana -u "$TARGET" -d 10 -jc -silent >> $OUTPUT_FILE

# Step 2: Combine and deduplicate URLs
echo "[*] Combining and deduplicating URLs..."
echo "" >> $OUTPUT_FILE
echo "## Deduplicated URLs ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | sort -u >> $OUTPUT_FILE

# Step 3: Analyze URLs with gf xss
echo "[*] Filtering for potential XSS patterns with gf..."
echo "" >> $OUTPUT_FILE
echo "## GF XSS Patterns ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | gf xss >> $OUTPUT_FILE

# Step 4: Clean URLs with uro
echo "[*] Cleaning and deduplicating URLs with uro..."
echo "" >> $OUTPUT_FILE
echo "## Cleaned URLs (uro) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | uro >> $OUTPUT_FILE

# Step 5: Test for Reflected Parameters with Gxss
echo "[*] Testing for reflected parameters with Gxss..."
echo "" >> $OUTPUT_FILE
echo "## Reflected Parameters (Gxss) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | Gxss >> $OUTPUT_FILE

# Step 6: Test for XSS with kxss
echo "[*] Testing for XSS vulnerabilities with kxss..."
echo "" >> $OUTPUT_FILE
echo "## Potential XSS Vulnerabilities (kxss) ##" >> $OUTPUT_FILE
cat $OUTPUT_FILE | kxss >> $OUTPUT_FILE

# Completion Message
echo "[*] HAWK completed. All results are saved in $OUTPUT_FILE"

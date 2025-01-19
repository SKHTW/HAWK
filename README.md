# **HAWK: Hunting Automated Workflow Kit**

## **Description**
HAWK (Hunting Automated Workflow Kit) is a powerful automation tool designed to streamline the process of discovering and assessing potential XSS vulnerabilities. By combining various tools, HAWK collects, filters, and tests URLs to identify potential XSS attack points.

Results are saved to a single output file, `Output.txt`, which can be used for manual testing or as input to other automation tools.

---

## **Features**
- Automated URL harvesting from:
  - **Wayback Machine**
  - **OTX (Open Threat Exchange)**
  - **Katana**
- Filters URLs using `gf xss` and cleans them with `uro`.
- Tests for vulnerabilities with `Gxss` and `kxss`.
- Ensures required tools are installed and ready to use.

---

## **Prerequisites**
1. **Supported OS**: Linux (e.g., ParrotOS, Kali, Ubuntu).
2. **Required Tools** (automatically installed if missing):
   - [Waybackurls](https://github.com/tomnomnom/waybackurls)
   - [Katana](https://github.com/projectdiscovery/katana)
   - [Gf](https://github.com/tomnomnom/gf)
   - [Uro](https://github.com/s0md3v/uro)
   - [Gxss](https://github.com/KathanP19/Gxss)
   - [Kxss](https://github.com/tomnomnom/hacks/tree/master/kxss)
3. **API Key for OTX**:
   - Sign up at [OTX AlienVault](https://otx.alienvault.com) to get an API key.
   - Insert the API key into the script (see **Configuration** below).

---

## **Installation**
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/HAWK.git
   cd HAWK

   
Make the script executable:
chmod +x hawk.sh

Configuration

Insert Your OTX API Key:
Open the script:
nano hawk.sh

Replace the placeholder in the following line with your API key:

OTX_API_KEY="your-otx-api-key"

Usage

Run the script with a target domain:
./hawk.sh <target-domain> 

Example:
./hawk.sh xss-game.appspot.com

Next Steps

Manual Testing:
Open Output.txt to review and test suspicious URLs.

Automation:
Use tools like XSStrike or XSpear to automate further XSS testing


Example Output

## URL Gathering ##
https://xss-game.appspot.com/
https://xss-game.appspot.com/static/game.js

## Deduplicated URLs ##
https://xss-game.appspot.com/
https://xss-game.appspot.com/static/game.js

## GF XSS Patterns ##
https://xss-game.appspot.com/?input=

## Cleaned URLs (uro) ##
https://xss-game.appspot.com/?input=

## Reflected Parameters (Gxss) ##
https://xss-game.appspot.com/?input=

## Potential XSS Vulnerabilities (kxss) ##
https://xss-game.appspot.com/?input=<script>alert(1)</script>


Limitations
Focused exclusively on XSS vulnerabilities.
Outputs require manual validation or further automation for accuracy.


License
This project is licensed under the MIT License. See the LICENSE file for details.

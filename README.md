**HAWK: Hunting Automated Workflow Kit**

**Description**
HAWK (Hunting Automated Workflow Kit) is a powerful tool designed to automate the discovery and assessment of potential XSS vulnerabilities. By integrating several specialized tools into a seamless workflow, HAWK simplifies the process of finding and analyzing vulnerable endpoints.

With live progress feedback and an elapsed time tracker, HAWK keeps you informed at every step, making vulnerability scanning efficient and transparent.

**Features**

Real-Time Feedback:

Watch as URLs are gathered and processed live in the terminal.
Monitor elapsed time for each stage of the scan.

**Automated URL Collection**:

Sources include:
Wayback Machine
OTX (Open Threat Exchange)
Katana
URL Processing and XSS Testing:

Filters with gf xss for potential XSS patterns.
Cleans and deduplicates with uro.
Tests for vulnerabilities using Gxss and kxss.

Ease of Use:
Global access: Run hawk from any directory.

Simple help flag (-h) for usage instructions.

Seamless Updates:

Update to the latest version with the -update flag.

API keys remain preserved during updates.


Installation
Clone the repository:


git clone https://github.com/SKHTW/HAWK.git
cd HAWK

Make the script executable:
chmod +x hawk.sh

Run the script:
./hawk.sh

Add HAWK to your PATH: 
The script will automatically add itself to /usr/local/bin for global usage on first run.

Usage
Basic Usage

To scan a target domain:
hawk <target-domain>

Help

For usage instructions:
hawk -h

Update

To update HAWK to the latest version:
hawk -update

Configuration
HAWK requires an API key for OTX (Open Threat Exchange). The script will prompt you for this key during its first run. The key is stored in ~/.hawk_config for future use and is not overwritten during updates.

Alternatively, you can manually add your key:
Open the configuration file:
nano ~/.hawk_config

Add your API key:
OTX_API_KEY=<your-api-key>

Features in Action
As URLs are gathered and processed, they are displayed in real-time.
For example:

[+] From Wayback Machine...
  Found URL: https://example.com/page1
  Found URL: https://example.com/page2
Elapsed Time Tracker:

After each stage, the script displays how long the process has been running:

[*] Elapsed Time: 00:05:32
Output File:

All results are saved to Output.txt, organized into sections such as:

## URL Gathering ##
https://example.com/page1
https://example.com/page2

## GF XSS Patterns ##
https://example.com/page1?input=

## Reflected Parameters (Gxss) ##
https://example.com/page1?input=

## Potential XSS Vulnerabilities (kxss) ##

https://example.com/page1?input=<script>alert(1)</script>
Example Workflow

Run HAWK:
hawk xss-game.appspot.com
Review Results: Open Output.txt to see potential XSS patterns and vulnerabilities.

**Manual or Automated Testing**:

Use tools like XSStrike or XSpear for deeper XSS testing.
Combine results with custom scripts for further analysis.

**Limitations**

XSS Focused: HAWK is specialized for XSS testing and does not scan for other types of vulnerabilities.
Manual Validation: Results require manual validation or further automation to confirm actual vulnerabilities.

**License**

This project is licensed under the MIT License. See the LICENSE file for details.


**Contributing**

Contributions are welcome! If you’d like to add features, improve the script, or report issues, feel free to submit a pull request or open an issue on GitHub.

Let’s secure the web together! 🚀

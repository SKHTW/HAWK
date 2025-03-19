Disclosure: Work In Progress, Right Now Need A Lot Of Space. Will Fix That Aspect. If website is large, can be over 1 TB of temp space. 

# HAWK: Hunting Automated Workflow Kit

## Description

HAWK (Hunting Automated Workflow Kit) is a powerful command-line tool designed to automate the discovery and assessment of potential Cross-Site Scripting (XSS) vulnerabilities. By integrating several specialized tools into a streamlined workflow, HAWK simplifies the process of finding and analyzing vulnerable endpoints.

With real-time progress feedback and an elapsed time tracker, HAWK provides clear visibility into the scanning process, making vulnerability assessments efficient and transparent.

## Features

* **Automated Tool Installation:** HAWK automatically checks for and installs required tools during its first run, simplifying setup.
* **Global Access:** Run HAWK from any directory after initial setup.
* **Real-Time Progress Tracking:** Monitor the progress of each stage with detailed feedback in the terminal.
* **Automated URL Collection:**
    * Sources include:
        * Wayback Machine
        * OTX (Open Threat Exchange)
        * Katana
* **XSS Vulnerability Scanning:**
    * Filters URLs with `gf xss` for potential XSS patterns.
    * Cleans and deduplicates URLs with `uro`.
    * Tests for vulnerabilities using `kxss`.
* **Seamless Updates:** Update HAWK to the latest version with the `-update` flag.
* **Configuration Persistence:** API keys and tool installation paths are stored securely and preserved during updates.
* **Automatic Update Check:** HAWK will automatically check for updates after each scan.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/SKHTW/HAWK.git](https://github.com/SKHTW/HAWK.git)
    cd HAWK
    ```
2.  **Make the script executable:**
    ```bash
    chmod +x hawk.sh
    ```
3.  **Run the script:**
    ```bash
    ./hawk.sh
    ```
    * The script will prompt you for your OTX API key and tool installation path on the first run.

## Usage

### Basic Usage

To scan a target domain:

```bash
hawk <target-domain>
```
Help

For usage instructions:
```bash

hawk -h
```
Update

To update HAWK to the latest version:
```bash

hawk -update
```
Configuration

HAWK requires an API key for OTX (Open Threat Exchange). The script will prompt you for this key and the tool installation path during its first run. The configuration is stored in ~/.hawk_config for future use and is not overwritten during updates.
Features in Action

As URLs are gathered and processed, they are displayed in real-time. For example:

[*] Gathering URLs...
  [+] From Wayback Machine...
  [https://example.com/page1](https://example.com/page1)
  [https://example.com/page2](https://example.com/page2)

Elapsed Time Tracker:

After each stage, the script displays how long the process has been running:

[*] HAWK completed in 00:05:32 seconds.

Output File:

All results are saved to Output.txt, organized into sections such as:

URL Gathering
[https://example.com/page1](https://example.com/page1)
[https://example.com/page2](https://example.com/page2)

GF XSS Patterns
[https://example.com/page1?input=](https://example.com/page1?input=)

Potential XSS Vulnerabilities (kxss)
[https://example.com/page1?input=](https://example.com/page1?input=)<script>alert(1)</script>

Example Workflow

  Run HAWK:
      ```bash
      hawk xss-game.appspot.com
      ```
    Review Results: Open Output.txt to see potential XSS patterns and vulnerabilities.
    Manual or Automated Testing: Use tools like XSStrike or XSpear for deeper XSS testing. Combine results with custom scripts for further analysis.

Limitations

  XSS Focused: HAWK is specialized for XSS testing and does not scan for other types of vulnerabilities.
  
  Manual Validation: Results require manual validation or further automation to confirm actual vulnerabilities.

License

This project is licensed under the MIT License. See the LICENSE file for details.
Contributing

Contributions are welcome! If you’d like to add features, improve the script, or report issues, feel free to submit a pull request or open an issue on GitHub.

Let’s secure the web together! 🚀

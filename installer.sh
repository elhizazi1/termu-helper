#!/bin/bash

# Define the repository URL for raw files
REPO_URL="https://raw.githubusercontent.com/elhizazi1/termu-helper/main"
INSTALL_DIR="$HOME/.termu-helper"
BIN_PATH="$PREFIX/bin/termu-helper"

# Check for required packages (curl and jq) and install them if they are missing
echo -e "\e[1;36m[+] Checking for required packages (curl and jq)...\e[0m"
pkg install -y curl jq || { echo -e "\e[1;31m[-] Error: Failed to install required packages. Exiting.\e[0m"; exit 1; }

# Create the installation directory if it doesn't exist
echo -e "\e[1;36m[+] Creating installation directory...\e[0m"
mkdir -p "$INSTALL_DIR"

# Download the core script and data file directly from GitHub
echo -e "\e[1;36m[+] Downloading files from GitHub...\e[0m"
curl -sL "$REPO_URL/termu-helper.sh" -o "$BIN_PATH" || { echo -e "\e[1;31m[-] Error: Failed to download termu-helper.sh. Exiting.\e[0m"; exit 1; }
curl -sL "$REPO_URL/commands.json" -o "$INSTALL_DIR/commands.json" || { echo -e "\e[1;31m[-] Error: Failed to download commands.json. Exiting.\e[0m"; exit 1; }

# Make the script executable
echo -e "\e[1;36m[+] Making the script executable...\e[0m"
chmod +x "$BIN_PATH"

echo ""
echo -e "\e[1;32m[+] Installation complete!\e[0m"
echo -e "\e[1;32m[+] You can now run the tool by typing: \e[1;33mtermu-helper\e[0m"

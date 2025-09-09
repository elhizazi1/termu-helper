#!/bin/bash

# Define the repository URL and installation paths
# OLD: REPO_URL="https://github.com/elhizazi1/termu-helper"
REPO_URL="git@github.com:elhizazi1/termu-helper.git" # Changed to SSH protocol
INSTALL_DIR="$HOME/.termu-helper"
BIN_PATH="$PREFIX/bin/termu-helper"

# Check for required packages (git and curl) and install them if they are missing
echo -e "\e[1;36m[+] Checking for required packages...\e[0m"
pkg install -y git curl || { echo -e "\e[1;31m[-] Error: Failed to install required packages. Exiting.\e[0m"; exit 1; }

# Create the installation directory if it doesn't exist
echo -e "\e[1;36m[+] Creating installation directory...\e[0m"
mkdir -p "$INSTALL_DIR"

# Clone the repository
if [ -d "$INSTALL_DIR/repo" ]; then
    echo -e "\e[1;33m[!] Repository already exists. Pulling latest changes...\e[0m"
    cd "$INSTALL_DIR/repo"
    git pull || { echo -e "\e[1;31m[-] Error: Failed to pull latest changes. Exiting.\e[0m"; exit 1; }
else
    echo -e "\e[1;36m[+] Cloning repository from GitHub...\e[0m"
    git clone "$REPO_URL" "$INSTALL_DIR/repo" || { echo -e "\e[1;31m[-] Error: Failed to clone repository. Exiting.\e[0m"; exit 1; }
fi

# Copy the core script and data file
echo -e "\e[1;36m[+] Copying files...\e[0m"
cp "$INSTALL_DIR/repo/termu-helper.sh" "$BIN_PATH"
cp "$INSTALL_DIR/repo/commands.json" "$INSTALL_DIR/"

# Make the script executable
echo -e "\e[1;36m[+] Making the script executable...\e[0m"
chmod +x "$BIN_PATH"

# Cleanup (optional but good practice)
# echo -e "\e[1;36m[+] Cleaning up temporary files...\e[0m"
# rm -rf "$INSTALL_DIR/repo"

echo ""
echo -e "\e[1;32m[+] Installation complete!\e[0m"
echo -e "\e[1;32m[+] You can now run the tool by typing: \e[1;33mtermu-helper\e[0m"

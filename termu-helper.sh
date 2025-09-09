#!/bin/bash

# ===========================
# Termux Helper - English Only
# Developed by Jamal El Hizazi
# ===========================

# Configuration
INSTALL_DIR="$HOME/.termu-helper"
DATA_FILE="$INSTALL_DIR/commands.json"
INDENT="          "  # 10 spaces for indentation

# Function to check if required tool 'jq' is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${INDENT}\e[1;31m* Error: 'jq' is not installed.\e[0m"
        echo "${INDENT}Installing 'jq' now..."
        pkg install -y jq
        if [ $? -ne 0 ]; then
            echo "${INDENT}Error: Failed to install 'jq'. Please install it manually with:"
            echo "${INDENT}pkg install jq"
            exit 1
        fi
    fi
}

# Function to display the main menu
display_menu() {
    clear
    echo -e "${INDENT}\e[1;36m┌────────────────────────────────────┐"
    echo -e "${INDENT}│ \e[1;33mTermux Helper - Commands List\e[1;36m │"
    echo -e "${INDENT}│ ✓ Developed by Jamal El Hizazi     │"
    echo -e "${INDENT}└────────────────────────────────────┘\e[0m"
    echo ""

    local current_category=""
    jq -r '.[] | .category + "!" + (.id | tostring) + ":" + .command' "$DATA_FILE" |
    while IFS="!" read -r category rest; do
        id_and_command=$(echo "$rest" | cut -d ':' -f 1-)
        id=$(echo "$id_and_command" | cut -d ':' -f 1)
        command=$(echo "$id_and_command" | cut -d ':' -f 2-)

        if [[ "$category" != "$current_category" ]]; then
            echo ""
            echo -e "${INDENT}• $category"
            current_category="$category"
        fi

        printf "${INDENT}  \e[1;32m%-2s\e[0m: %s\n" "$id" "$command"
    done

    echo ""
    echo -e "${INDENT}---------------------------------------"
    echo -e "${INDENT}Enter a command number for details, or 'q' to quit."
}

# Function to show command details
show_details() {
    local id=$1
    local command_info=$(jq --argjson id "$id" '.[] | select(.id == $id)' "$DATA_FILE")

    if [ -n "$command_info" ]; then
        local cmd_name=$(echo "$command_info" | jq -r '.command')
        local cmd_desc=$(echo "$command_info" | jq -r '.description')
        local cmd_example=$(echo "$command_info" | jq -r '.example')

        clear
        echo -e "${INDENT}\e[1;36m┌────────────────────────────────────┐"
        echo -e "${INDENT}│ \e[1;33mCommand Details\e[1;36m          │"
        echo -e "${INDENT}└────────────────────────────────────┘\e[0m"
        echo -e "${INDENT}✓ Command: $cmd_name"
        echo -e "${INDENT}° Description: $cmd_desc"
        echo -e "${INDENT}• Example: $cmd_example"
        echo ""
        echo -e "${INDENT}---------------------------------------"
        echo -e "${INDENT}To copy the command, select the text above."
        echo -e "${INDENT}Press Enter to return to the main menu."
        read -p ""
    else
        echo -e "${INDENT}\e[1;31m* Error: Invalid command number.\e[0m"
        sleep 2
    fi
}

# ===========================
# Main Loop
# ===========================
check_jq

while true; do
    display_menu
    read -p "> " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        show_details "$choice"
    elif [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "${INDENT}Thanks for using Termux Helper!"
        exit 0
    else
        echo -e "${INDENT}\e[1;31m* Invalid input. Please enter a number or 'q'.\e[0m"
        sleep 2
    fi
done

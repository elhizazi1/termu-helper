#!/bin/bash

# Configuration
DATA_FILE="$HOME/.termu-helper/commands.json"
INSTALL_DIR="$HOME/.termu-helper"

# Function to check if required tool 'jq' is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "======================================"
        echo -e "\e[1;31mError: 'jq' is not installed.\e[0m"
        echo "The 'jq' tool is required for this to work correctly."
        echo "======================================"
        echo "Installing 'jq' now..."
        pkg install -y jq
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install 'jq'. Please install it manually with:"
            echo "pkg install jq"
            exit 1
        fi
    fi
}

# Function to display the main menu
display_menu() {
    clear
    echo -e "\e[1;36m┌────────────────────────────────────┐"
    echo -e "│ \e[1;33mTermux Helper - Commands List\e[1;36m      │"
    echo -e "└────────────────────────────────────┘\e[0m"
    echo ""

    local current_category=""
    jq -r '.[] | .category + "!" + (.id | tostring) + ":" + .command' "$DATA_FILE" |
    while IFS="!" read -r category rest; do
        id_and_command=$(echo "$rest" | cut -d ':' -f 1-)
        id=$(echo "$id_and_command" | cut -d ':' -f 1)
        command=$(echo "$id_and_command" | cut -d ':' -f 2-)
        
        if [[ "$category" != "$current_category" ]]; then
            echo ""
            echo -e "\e[1;35m$category\e[0m"
            current_category="$category"
        fi
        
        printf "  \e[1;32m%-2s\e[0m: %s\n" "$id" "$command"
    done

    echo ""
    echo -e "\e[1;33m---------------------------------------\e[0m"
    echo -e "\e[1;33mEnter a command number for details, or 'q' to quit.\e[0m"
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
        echo -e "\e[1;36m┌────────────────────────────────────┐"
        echo -e "│ \e[1;33mCommand Details\e[1;36m              │"
        echo -e "└────────────────────────────────────┘\e[0m"
        echo -e "\e[1;32mCommand:\e[0m $cmd_name"
        echo -e "\e[1;32mDescription:\e[0m $cmd_desc"
        echo -e "\e[1;32mExample:\e[0m $cmd_example"

        echo ""
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "\e[1;33mTo copy the command, select the text above.\e[0m"
        echo -e "\e[1;33mPress Enter to return to the main menu.\e[0m"
        read -p ""

    else
        echo -e "\e[1;31mError: Invalid command number.\e[0m"
        sleep 2
    fi
}

# Main loop
check_jq
while true; do
    display_menu
    read -p "> " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        show_details "$choice"
    elif [ "$choice" == "q" ] || [ "$choice" == "Q" ]; then
        echo "Thanks for using Termux Helper!"
        exit 0
    else
        echo -e "\e[1;31mInvalid input. Please enter a number or 'q'.\e[0m"
        sleep 2
    fi
done

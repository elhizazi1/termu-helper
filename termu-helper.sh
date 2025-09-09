#!/bin/bash

# ===========================
# Termux Helper - Multilingual
# ===========================

# Configuration
INSTALL_DIR="$HOME/.termu-helper"
DATA_FILE_EN="$INSTALL_DIR/commands.json"
DATA_FILE_AR="$INSTALL_DIR/commands.ar.json"
DEVELOPER="Jamal El Hizazi"

# Function to check if required tool 'jq' is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "\e[1;31mError: 'jq' is not installed.\e[0m"
        echo "Installing 'jq' now..."
        pkg install -y jq
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install 'jq'. Please install it manually with:"
            echo "pkg install jq"
            exit 1
        fi
    fi
}

# Function to choose language
choose_language() {
    clear
    echo -e "\e[1;36m┌──────────────────────────────┐"
    echo -e "│ \e[1;33mTermux Helper - Language\e[1;36m │"
    echo -e "└──────────────────────────────┘\e[0m"
    echo ""
    echo -e "1: English"
    echo -e "2: العربية"
    echo ""
    read -p "Select language / اختر اللغة (1/2): " lang_choice
    case "$lang_choice" in
        2) DATA_FILE="$DATA_FILE_AR";;
        *) DATA_FILE="$DATA_FILE_EN";;
    esac
}

# Function to display header with developer name
display_header() {
    clear
    echo -e "\e[1;36m┌────────────────────────────────────┐"
    if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
        echo -e "│ \e[1;33mأداة Termux Helper\e[1;36m              │"
        echo -e "│ \e[1;32mتم التطوير بواسطة: $DEVELOPER\e[1;36m │"
    else
        echo -e "│ \e[1;33mTermux Helper - Commands List\e[1;36m │"
        echo -e "│ \e[1;32mDeveloped by: $DEVELOPER\e[1;36m       │"
    fi
    echo -e "└────────────────────────────────────┘\e[0m"
    echo ""
}

# Function to display the main menu
display_menu() {
    display_header
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
    if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "\e[1;33mأدخل رقم الأمر للتفاصيل، أو 'q' للخروج.\e[0m"
    else
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "\e[1;33mEnter a command number for details, or 'q' to quit.\e[0m"
    fi
}

# Function to show command details
show_details() {
    local id=$1
    local command_info=$(jq --argjson id "$id" '.[] | select(.id == $id)' "$DATA_FILE")

    if [ -n "$command_info" ]; then
        local cmd_name=$(echo "$command_info" | jq -r '.command')
        local cmd_desc=$(echo "$command_info" | jq -r '.description')
        local cmd_example=$(echo "$command_info" | jq -r '.example')

        display_header
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;33mتفاصيل الأمر\e[0m"
        else
            echo -e "\e[1;33mCommand Details\e[0m"
        fi
        echo -e "\e[1;32mCommand:\e[0m $cmd_name"
        echo -e "\e[1;32mDescription:\e[0m $cmd_desc"
        echo -e "\e[1;32mExample:\e[0m $cmd_example"

        echo ""
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;33m---------------------------------------\e[0m"
            echo -e "\e[1;33mلنسخ الأمر، قم بتحديد النص أعلاه.\e[0m"
            echo -e "\e[1;33mاضغط Enter للعودة إلى القائمة الرئيسية.\e[0m"
        else
            echo -e "\e[1;33m---------------------------------------\e[0m"
            echo -e "\e[1;33mTo copy the command, select the text above.\e[0m"
            echo -e "\e[1;33mPress Enter to return to the main menu.\e[0m"
        fi
        read -p ""
    else
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;31mخطأ: رقم أمر غير صحيح.\e[0m"
        else
            echo -e "\e[1;31mError: Invalid command number.\e[0m"
        fi
        sleep 2
    fi
}

# ===========================
# Main Loop
# ===========================
check_jq
choose_language

while true; do
    display_menu
    read -p "> " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        show_details "$choice"
    elif [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo "شكراً لاستخدام Termux Helper!"
        else
            echo "Thanks for using Termux Helper!"
        fi
        exit 0
    else
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;31mإدخال غير صالح. الرجاء إدخال رقم أو 'q'.\e[0m"
        else
            echo -e "\e[1;31mInvalid input. Please enter a number or 'q'.\e[0m"
        fi
        sleep 2
    fi
done
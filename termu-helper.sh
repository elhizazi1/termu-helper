#!/bin/bash

# ===========================
# Termux Helper - Multilingual RTL Friendly
# Developed by Jamal El Hizazi
# ===========================

INSTALL_DIR="$HOME/.termu-helper"
DATA_FILE_EN="$INSTALL_DIR/commands.json"
DATA_FILE_AR="$INSTALL_DIR/commands.ar.json"
DEV_NAME="جمال الحزازي"

# Reverse Arabic text for RTL display
reverse_text() {
    local input="$1"
    echo "$input" | rev
}

# Check jq
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "\e[1;31mError: 'jq' is not installed.\e[0m"
        echo "Installing 'jq' now..."
        pkg install -y jq
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install 'jq'. Install manually: pkg install jq"
            exit 1
        fi
    fi
}

# Choose language
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

# Display menu
display_menu() {
    clear
    if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
        echo -e "\e[1;36m┌────────────────────────────────────┐"
        echo -e "│ $(reverse_text 'Termux Helper - قائمة الأوامر') │"
        echo -e "│ $(reverse_text "تم التطوير بواسطة $DEV_NAME") │"
        echo -e "└────────────────────────────────────┘\e[0m"
    else
        echo -e "\e[1;36m┌────────────────────────────────────┐"
        echo -e "│ \e[1;33mTermux Helper - Commands List\e[1;36m │"
        echo -e "│ Developed by $DEV_NAME │"
        echo -e "└────────────────────────────────────┘\e[0m"
    fi
    echo ""

    local current_category=""
    jq -r '.[] | .category + "!" + (.id | tostring) + ":" + .command' "$DATA_FILE" |
    while IFS="!" read -r category rest; do
        id_and_command=$(echo "$rest" | cut -d ':' -f 1-)
        id=$(echo "$id_and_command" | cut -d ':' -f 1)
        command=$(echo "$id_and_command" | cut -d ':' -f 2-)

        if [[ "$category" != "$current_category" ]]; then
            echo ""
            if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
                echo -e "$(reverse_text "$category")"
            else
                echo -e "\e[1;35m$category\e[0m"
            fi
            current_category="$category"
        fi

        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            printf "  \e[1;32m%-2s\e[0m: %s\n" "$id" "$(reverse_text "$command")"
        else
            printf "  \e[1;32m%-2s\e[0m: %s\n" "$id" "$command"
        fi
    done

    echo ""
    if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "$(reverse_text 'أدخل رقم الأمر للتفاصيل، أو q للخروج.')"
    else
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "\e[1;33mEnter a command number for details, or 'q' to quit.\e[0m"
    fi
}

# Show command details
show_details() {
    local id=$1
    local command_info=$(jq --argjson id "$id" '.[] | select(.id == $id)' "$DATA_FILE")

    if [ -n "$command_info" ]; then
        local cmd_name=$(echo "$command_info" | jq -r '.command')
        local cmd_desc=$(echo "$command_info" | jq -r '.description')
        local cmd_example=$(echo "$command_info" | jq -r '.example')

        clear
        echo -e "\e[1;36m┌────────────────────────────────────┐"
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "│ $(reverse_text 'تفاصيل الأمر')              │"
            echo -e "│ $(reverse_text "تم التطوير بواسطة $DEV_NAME") │"
        else
            echo -e "│ \e[1;33mCommand Details\e[1;36m          │"
            echo -e "│ Developed by $DEV_NAME │"
        fi
        echo -e "└────────────────────────────────────┘\e[0m"

        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "$(reverse_text "Command:") $(reverse_text "$cmd_name")"
            echo -e "$(reverse_text "Description:") $(reverse_text "$cmd_desc")"
            echo -e "$(reverse_text "Example:") $(reverse_text "$cmd_example")"
            echo ""
            echo -e "\e[1;33m---------------------------------------\e[0m"
            echo -e "$(reverse_text 'لنسخ الأمر، قم بتحديد النص أعلاه.')"
            echo -e "$(reverse_text 'اضغط Enter للعودة إلى القائمة الرئيسية.')"
        else
            echo -e "\e[1;32mCommand:\e[0m $cmd_name"
            echo -e "\e[1;32mDescription:\e[0m $cmd_desc"
            echo -e "\e[1;32mExample:\e[0m $cmd_example"
            echo ""
            echo -e "\e[1;33m---------------------------------------\e[0m"
            echo -e "\e[1;33mTo copy the command, select the text above.\e[0m"
            echo -e "\e[1;33mPress Enter to return to the main menu.\e[0m"
        fi
        read -p ""
    else
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;31m$(reverse_text 'خطأ: رقم أمر غير صحيح.')\e[0m"
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
            echo "$(reverse_text 'شكراً لاستخدام Termux Helper!')"
        else
            echo "Thanks for using Termux Helper!"
        fi
        exit 0
    else
        if [[ "$DATA_FILE" == "$DATA_FILE_AR" ]]; then
            echo -e "\e[1;31m$(reverse_text 'إدخال غير صالح. الرجاء إدخال رقم أو q.')\e[0m"
        else
            echo -e "\e[1;31mInvalid input. Please enter a number or 'q'.\e[0m"
        fi
        sleep 2
    fi
done
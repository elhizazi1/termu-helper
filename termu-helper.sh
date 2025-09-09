#!/bin/bash

# Configuration
DATA_FILE="$HOME/.termu-helper/commands.json"
INSTALL_DIR="$HOME/.termu-helper"

# Function to check if required tool 'jq' is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "======================================"
        echo -e "\e[1;31mخطأ: أداة 'jq' غير مثبتة.\e[0m"
        echo -e "أداة jq ضرورية لعمل هذه الأداة بشكل صحيح."
        echo "======================================"
        echo "جارٍ تثبيت 'jq' الآن..."
        pkg install -y jq
        if [ $? -ne 0 ]; then
            echo "خطأ: فشل تثبيت 'jq'. يرجى تثبيتها يدوياً باستخدام:"
            echo "pkg install jq"
            exit 1
        fi
    fi
}

# Function to display the main menu
display_menu() {
    clear
    echo -e "\e[1;36m┌────────────────────────────────────┐"
    echo -e "│ \e[1;33mTermux Helper - قائمة الأوامر\e[1;36m      │"
    echo -e "└────────────────────────────────────┘\e[0m"
    echo ""
    
    local current_category=""
    jq -r '.[] | "\e[1;35m\(.category)\e[0m: \e[1;32m\(.id)\e[0m: \(.command)"' "$DATA_FILE" |
    while IFS= read -r line; do
        category=$(echo "$line" | cut -d ':' -f 1 | sed 's/\\e\[1;35m//g' | sed 's/\\e\[0m//g')
        if [[ "$category" != "$current_category" ]]; then
            echo ""
            echo -e "\e[1;35m$category\e[0m"
            current_category="$category"
        fi
        echo -e "\t$(echo "$line" | cut -d ':' -f 2-)"
    done
    
    echo ""
    echo -e "\e[1;33m---------------------------------------\e[0m"
    echo -e "\e[1;33mأدخل رقم الأمر لعرض التفاصيل، أو 'q' للخروج.\e[0m"
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
        echo -e "│ \e[1;33mتفاصيل الأمر\e[1;36m                 │"
        echo -e "└────────────────────────────────────┘\e[0m"
        echo -e "\e[1;32mالأمر:\e[0m $cmd_name"
        echo -e "\e[1;32mالوصف:\e[0m $cmd_desc"
        echo -e "\e[1;32mمثال:\e[0m $cmd_example"
        
        echo ""
        echo -e "\e[1;33m---------------------------------------\e[0m"
        echo -e "\e[1;33mلنسخ الأمر، قم بتحديد النص أعلاه.\e[0m"
        echo -e "\e[1;33mاضغط Enter للعودة إلى القائمة الرئيسية.\e[0m"
        read -p ""
        
    else
        echo -e "\e[1;31mخطأ: رقم الأمر غير صالح.\e[0m"
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
        echo "شكراً لاستخدامك Termux Helper!"
        exit 0
    else
        echo -e "\e[1;31mمدخل غير صالح. يرجى إدخال رقم أو 'q'.\e[0m"
        sleep 2
    fi
done


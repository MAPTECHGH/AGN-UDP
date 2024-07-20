#!/bin/bash

CONFIG_DIR="/etc/hysteria"
CONFIG_FILE="$CONFIG_DIR/config.json"
USER_DB="$CONFIG_DIR/udpusers.db"
SYSTEMD_SERVICE="/etc/systemd/system/hysteria-server.service"

mkdir -p "$CONFIG_DIR"
touch "$USER_DB"

add_user() {
    echo "Enter username:"
    read -r username
    echo "Enter password:"
    read -r password

    echo "$username:$password" >> "$USER_DB"

    local users=""
    while IFS=: read -r user pass; do
        users+="\"$user\":\"$pass\","
    done < "$USER_DB"
    users="${users%,}"

    jq ".auth.userpass = { $users }" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "User $username added successfully."

    restart_server
}

change_domain() {
    echo "Enter new domain:"
    read -r domain

    jq ".server = \"$domain\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "Domain changed to $domain successfully."

    restart_server
}

change_obfs() {
    echo "Enter new obfuscation string:"
    read -r obfs

    jq ".obfs = \"$obfs\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "Obfuscation string changed to $obfs successfully."

    restart_server
}

change_up_speed() {
    echo "Enter new upload speed (Mbps):"
    read -r up_speed

    jq ".up = \"$up_speed Mbps\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    jq ".up_mbps = $up_speed" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "Upload speed changed to $up_speed Mbps successfully."

    restart_server
}

change_down_speed() {
    echo "Enter new download speed (Mbps):"
    read -r down_speed

    jq ".down = \"$down_speed Mbps\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    jq ".down_mbps = $down_speed" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "Download speed changed to $down_speed Mbps successfully."

    restart_server
}

show_menu() {
    echo "----------------------------"
    echo " AGNUDP Manager"
    echo "----------------------------"
    echo "1. Add new user"
    echo "2. Change domain"
    echo "3. Change obfuscation string"
    echo "4. Change upload speed"
    echo "5. Change download speed"
    echo "6. Restart server"
    echo "7. Uninstall server"
    echo "8. Exit"
    echo "----------------------------"
    echo "Enter your choice: "
}

restart_server() {
    systemctl restart hysteria-server
    echo "Server restarted successfully."
}

show_banner() {
    echo "---------------------------------------------"
    echo " AGNUDP Manager"
    echo " (c) 2023 Khaled AGN"
    echo " Telegram: @khaledagn"
    echo "---------------------------------------------"
}

uninstall_server() {
    echo "Uninstalling AGN-UDP server..."

    systemctl stop hysteria-server
    systemctl disable hysteria-server

    rm -f "$SYSTEMD_SERVICE"
    systemctl daemon-reload

    rm -rf "$CONFIG_DIR"

    rm -f /usr/local/bin/hysteria

    echo "AGN-UDP server uninstalled successfully."
}

show_banner
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            add_user
            ;;
        2)
            change_domain
            ;;
        3)
            change_obfs
            ;;
        4)
            change_up_speed
            ;;
        5)
            change_down_speed
            ;;
        6)
            restart_server
            ;;
        7)
            uninstall_server
            exit 0
            ;;
        8)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

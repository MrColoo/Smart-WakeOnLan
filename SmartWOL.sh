#!/bin/bash

################################################################################
# Script: auto-wake-on-lan.sh
# Description: Script to monitor UPS status, detect power loss, send alerts via Telegram and wake up servers automatically using Wake-on-LAN.
# Author: MrColo
# Copyright (c) 2024 MrColo
# License: MIT License
################################################################################

# IMPORTANT: Before running this script, ensure you have completed the following steps:

# 1. UPS Configuration:
#    - Replace UPS_IP with the actual IP address of your UPS.
#    - Set up Network UPS Tools (NUT) on your NAS or Server and connect the UPS.

# 2. Server Configuration:
#    - Update HOSTS, NICKNAMES, and MACADDRS arrays with your server details.
#    - Ensure Wake-on-LAN (WOL) is enabled on your servers.

# 3. Telegram Bot Configuration:
#    - Create a Telegram bot using the BotFather on Telegram.
#    - Replace [Your Token] and [Your Chat ID] with your actual API token and chat ID.

# 4. Dependency Installation:
#    - Install the wakeonlan tool. (Example: sudo apt-get install wakeonlan)
#    - Ensure the ping command is available.

# 5. Execution:
#    - Make the script executable: chmod +x auto-wake-on-lan.sh
#    - Run the script periodically using a cron job or manually: ./auto-wake-on-lan.sh

# 6. Frequency:
#    - Consider scheduling the script to run at regular intervals, e.g., every 5 minutes.
#      type: crontab -e
#       and paste: */5 * * * * /path/to/your/script/power-on-server.sh     to run it every 5  minutes


# 7. Telegram Notifications:
#    - Ensure the Telegram bot has permission to send messages to the specified chat ID.

# IMPORTANT NOTES:
# - Customize the script based on your specific server setup and requirements.
# - Monitor the script's output and adjust configurations as needed.

# For detailed instructions, refer to the README.md file.

# ---
# Author: MrColo
# Copyright (c) 2024 MrColo
# License: MIT License

#######################################################################################

# Setup
HOSTS=(192.168.1.34) #IPs of your servers Ex. HOSTS=(192.168.1.1 10.10.10.1)
NICKNAMES=("MyFavourite1") #Servers friendly names Ex. NICKNAMES=("Server1" "Server2")
MACADDRS=(SM:AR:TW:AK:EU:P0) #Mac Addresses Ex. MACADDRS=(xx:xx:xx:xx:xx:xx)
UPS_IP="192.168.1.35"  # IP of NUT server or UPS
WOL_PORT=9
WOL_COMMAND="wakeonlan"
STATE_FILE="/tmp/ups_script_state.txt" # Temp file to keep track of an already sent telegram message of power outage

# Telegram Bot Setup
TOKEN="" #Put here your Bot TOKEN
CHAT_ID="" #Put here your CHAT_ID

# Function to check the UPS status and monitor power loss
check_ups_status() {
    local ups_status=$(upsc ups@${UPS_IP} ups.status)
    local current_time=$(date +"%s")

    # Check for power loss
    if [ "${ups_status}" != "OL" ] && [ "${ups_status}" != "OL CHRG" ]; then
    # Check if the message has already been sent in the last 24 hours
        if [ -f "${STATE_FILE}" ]; then
            local last_power_loss_time=$(cat "${STATE_FILE}")
            local time_diff=$((current_time - last_power_loss_time))
            local time_limit=$((24 * 60 * 60))  # 24 hours in seconds

            if [ ${time_diff} -lt ${time_limit} ]; then
                echo "Power loss detected, but message already sent within the last 24 hours. Skipping."
                return
            fi
        fi

        # local event_message=$(upsc ups@${UPS_IP} ups.alarm)
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        local telegram_message="Power loss detected! Date and time: ${timestamp}"
        send_message "${telegram_message}"

        # Save the timestamp in the state file
        echo "${current_time}" > "${STATE_FILE}"

        echo "Power loss detected. Telegram message sent."
    else
        # If UPS is powered, delete the state file
        [ -f "${STATE_FILE}" ] && rm "${STATE_FILE}"

        echo "UPS is powered. Checking servers..."

        # Flag to check if at least one server is down
        server_down=false

        # Check the status of servers
        for ((i=0; i<${#HOSTS[@]}; i++)); do
            if ! /bin/ping -q -c1 "${HOSTS[i]}" &>/dev/null; then
                echo "${NICKNAMES[i]} is down. Attempting to wake up..."
                wake_up_servers "${NICKNAMES[i]}" "${HOSTS[i]}" "${MACADDRS[i]}"
                server_down=true
            else
                echo "${NICKNAMES[i]} is up."
            fi
        done
    fi
}

# Function to power on a server using Wake-on-LAN
wake_up_servers() {
    local nickname=$1
    local host=$2
    local mac_address=$3
    ${WOL_COMMAND} -p ${WOL_PORT} ${mac_address}
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local telegram_message="Attempt to power on ${nickname} (${host}, MAC: ${mac_address}) Date and time: ${timestamp}"
    send_message "${telegram_message}"
    echo "Sent WOL to ${mac_address}. Telegram message sent."
}

# Function to send a message on Telegram
send_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d "chat_id=${CHAT_ID}" -d "text=${message}" > /dev/null
}

# Execute the UPS and power loss check
check_ups_status

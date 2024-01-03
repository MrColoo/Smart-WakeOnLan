# Smart-WakeOnLan
🚀 Smart WakeOnLan Script: Monitor UPS, automatic wake servers with WOL after power outage, and get Telegram alerts. Simple setup, customizable, and reliable. Keep your servers running seamlessly! 🌐⚡

## 🌟 Features

- **UPS Monitoring:** Check UPS status and detect power loss.
- **Server Wake-up:** Use Wake-on-LAN to power up servers.
- **Telegram Notifications:** Get real-time alerts for power events and server status.
- **Customizable:** Easily configure for different server setups.

## ⚙️ Requirements

- Bash Shell
- Wake-on-LAN (WOL) tool
- ping command
- NUT (Network UPS Tools) server (e.g., on a Synology NAS)
- Telegram Bot for notifications

## 🛠️ Configuration Steps

1. **UPS Configuration:**
   - Set the `UPS_IP` variable with your UPS's IP.
   - Ensure NUT is set up on your NAS.

2. **Server Configuration:**
   - Update `HOSTS`, `NICKNAMES`, and `MACADDRS` arrays with your server details.
   - Confirm Wake-on-LAN (WOL) is enabled.

3. **Telegram Bot Configuration:**
   - Create a Telegram bot and replace `[Your Token]` and `[Your Chat ID]`.

4. **Dependency Installation:**
   - Install the wakeonlan tool (e.g., `sudo apt-get install wakeonlan`).
   - Ensure the ping command is available.

5. **Execution:**
   - Make the script executable: `chmod +x power-on-server.sh`
   - Run the script periodically (e.g., every 5 minutes) using a cron job.

## 🚀 Usage

- Schedule the script to run periodically.
- Receive Telegram notifications for UPS and server status.

## 📝 Important Notes

- Customize the script based on your server setup.
- Check the [full documentation](link_to_docs) for detailed instructions.

## 🧑‍💻 Author

[Your Name]

## 📄 License

This project is licensed under the MIT License.

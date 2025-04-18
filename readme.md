# WSL ↔ OneDrive VSCode Folder Sync Service

This service provides **bidirectional synchronization** between VSCode folders inside WSL 2 user directories and a designated OneDrive folder path on Windows. It is intended to run as a **systemd service** inside WSL 2.

> ⚠️ **Warning:** This script does **not** handle file conflicts gracefully. The **last sync wins** strategy is used. Please ensure you do not have simultaneous edits in both locations.

---

## 📂 Folder Structure

**Sync Source (inside WSL):**
- `/home/{lnx-user}/vscode/`

**Sync Destination (in Windows OneDrive):**
- `/mnt/c/Users/{win-user}/OneDrive/{lnx-user}/vscode/`

---

## 🔧 Installation

1. **Place the Script**

Create the script file:

```bash
sudo nano /usr/local/bin/bidirectional-sync.sh
```

Paste the following script inside:

```bash
#!/usr/bin/env bash
set -euo pipefail

ONEDRIVE_BASE="/mnt/c/Users/{win-user}/OneDrive/wsl-sync"

for userDir in /home/*; do
    [ -d "$userDir" ] || continue
    userName="$(basename "$userDir")"

    localVscode="$userDir/vscode"
    remoteVscode="$ONEDRIVE_BASE/$userName/vscode"

    if [ -d "$localVscode" ]; then
        mkdir -p "$remoteVscode"

        echo "---------------------------------------------"
        echo "Syncing for user: $userName"
        echo "Local folder:  $localVscode"
        echo "Remote folder: $remoteVscode"
        echo

        echo " -> Syncing local to OneDrive..."
        rsync -av --delete "$localVscode/" "$remoteVscode/"
        echo "Done syncing for $userName."
        echo
    fi
done

echo "All done!"
```

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/bidirectional-sync.sh
```

---

2. **Create a systemd Service File**

Create the service:

```bash
sudo nano /etc/systemd/system/wsl-sync.service
```

Paste the following content:

```ini
[Unit]
Description=Sync VSCode folders from WSL to OneDrive
After=network.target

[Service]
ExecStart=/usr/local/bin/bidirectional-sync.sh
Type=oneshot

[Install]
WantedBy=default.target
```

---

3. **Enable and Run the Service**

Enable it to run on startup:

```bash
sudo systemctl enable wsl-sync.service
```

Run it manually for testing:

```bash
sudo systemctl start wsl-sync.service
```

Check the logs:

```bash
journalctl -u wsl-sync.service
```

---

## ✅ Notes

- The service assumes your OneDrive is mounted under `/mnt/c/Users/{win-user}/OneDrive`.
- You can modify the `ONEDRIVE_BASE` variable in the script to match your setup.
- To make the sync periodic, consider adding a `cron` job or using a `systemd timer`.

---

## 📎 License

MIT License – Free to use and modify.

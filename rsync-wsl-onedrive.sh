#!/usr/bin/env bash
#
# bidirectional-sync.sh
#
# Synchronizes /home/{user}/vscode with /mnt/c/Users/Mateo/OneDrive/vscode/{user}/vscode
# for all user directories in /home/ that contain a 'vscode' folder.
#
# WARNING: This does not handle file conflicts gracefully. Last sync wins.

set -euo pipefail

# Change this to match your actual OneDrive path under /mnt/c
ONEDRIVE_BASE="/mnt/c/Users/Mateo/OneDrive/vscode"

# Loop through all directories in /home (excluding special system directories if any)
for userDir in /home/*; do
    # Make sure it's actually a directory
    [ -d "$userDir" ] || continue

    # Extract just the username from the path (e.g. /home/bob -> bob)
    userName="$(basename "$userDir")"

    localVscode="$userDir/vscode"
    remoteVscode="$ONEDRIVE_BASE/$userName/vscode"

    # Check if there's a 'vscode' folder locally to sync
    if [ -d "$localVscode" ]; then
        # Ensure the remote (OneDrive) folder exists
        mkdir -p "$remoteVscode"

        echo "---------------------------------------------"
        echo "Syncing for user: $userName"
        echo "Local folder:  $localVscode"
        echo "Remote folder: $remoteVscode"
        echo

        # 1) Pull new/updated files from local WSL -> OneDrive
        echo " -> Syncing local to OneDrive..."
        rsync -av --delete \
            "$localVscode/" \
            "$remoteVscode/"

        echo "Done syncing for $userName."
        echo
    fi
done

echo "All done!"

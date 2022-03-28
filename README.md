## Proxmox helper scripts

This repo contains some Proxmox helper scripts

### backup-hook.sh

This is a simple backup hook script for LXC containers. The goal is to run specific tasks inside the container at certain points during the backup process. For example, stopping a process before the backup begins and restarting it when the backup is done.

Usage:

 1. Download the script somewhere on your Proxmox server.
 2. Make it executable: `chmod +x backup-hook.sh`
 3. Tell vzdump to use it by setting the "script" variable in `/etc/vzdump.conf`

This makes Proxmox call the script at specific event during the process of backing up an LXC container. The script, in turn, checks if a script with the same name as the event exists within the container, and if it does, executes it. So for example, to run a task inside a container at the beginning of the backup process, create it as `/root/backup-start.sh`.

List of possible events:

 - backup-start
 - pre-stop
 - pre-restart
 - post-restart
 - backup-end
 - backup-abort
 - log-end

There's no need to create scripts for all events, backup-hook.sh will only execute the ones that actually exist.

Note: This script isn't suited for backup-related tasks that need to be performed *outside* the container, e.g. copying the backup file to an off-site server.

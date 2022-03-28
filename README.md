[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/IndrekHaav/proxmox-helpers/lint?label=lint)](https://github.com/IndrekHaav/proxmox-helpers/actions/workflows/lint.yml)

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

### lxc-setup.sh

This is a boilerplate script for automating setup tasks in new LXC containers (installing packages, making configuration changes and so on). When run on a Proxmox host, it copies itself into the specified container, executes itself there and then removes itself. Inside the container, it executes whatever instructions are put in the `setup ()` function.

Usage:

 1. Download the script somewhere on your Proxmox server.
 2. Make it executable: `chmod +x lxc-setup.sh`
 3. Edit the script and put the tasks you want to be executed inside the container, into the `setup ()` function at the top of the script.
 4. Call the script with `./lxc-setup.sh XYZ` (replacing XYZ with the numeric ID of the container).

#!/bin/bash
#
# Author: Indrek Haav
# Source: https://github.com/IndrekHaav/proxmox-helpers

set -e

setup () {
    # anything in this function will be executed inside the container
    echo "Setup starting on $(date)"
}

if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root!"
    exit 1
fi

if [ "${container:=}" == "lxc" ]; then
    # we're inside the container, so call the setup function and exit
    setup
    exit 0
fi

# the following runs on the host

if ! command -v pct > /dev/null; then
    echo "Error: pct not found. Are you running on Proxmox?"
    exit 1
fi

script_name=$(basename "$0")
ctid=$1
if [ -z "$ctid" ]; then
    echo "Usage: $script_name <CTID>"
    exit 1
fi

if ! status=$(pct status "$ctid" 2>/dev/null); then
    echo "Error: container $ctid not found!"
    exit 1
fi
if [ "$status" != "status: running" ]; then
    echo "Error: container $ctid is not running!"
    exit 1
fi

hostname=$(pct exec "$ctid" hostname)
echo "Setting up container $ctid ($hostname)"

echo "Copying script to container... "
if ! pct push "$ctid" "$0" "/root/$script_name" --perms 760; then
    echo "Error: unable to push script to container; please copy manually."
    exit 1
fi

echo "Executing script..."
pct exec "$ctid" -- bash -c "/root/$script_name | tee /root/setup.log"

echo "Cleaning up... "
pct exec "$ctid" rm "/root/$script_name"

echo "DONE"
exit 0

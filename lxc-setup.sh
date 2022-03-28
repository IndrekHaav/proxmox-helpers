#!/bin/bash

set -e

setup () {
    # anything in this function will be executed inside the container

    logfile="setup.log"
    date > $logfile
    # write to the logfile by appending "&>> $logfile" to commands
}

if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root!"
    exit 1
fi

if [ "${container:=}" != "lxc" ]; then
    script_name=$(basename "$0")

    if ! command -v pct > /dev/null; then
        echo "Error: pct not found. Are you running on Proxmox?"
        exit 1
    fi

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
    pct exec "$ctid" "/root/$script_name"

    echo "Cleaning up... "
    pct exec "$ctid" rm "/root/$script_name"

    echo "DONE"
    exit 0
fi

# if we got this far, we're inside the container, so call the setup function
setup

exit 0

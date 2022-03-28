#!/bin/bash

if [ "$VMTYPE" == "lxc" ]; then
    echo "Running $1 script in guest $3 (if it exists)"
    pct exec "$3" -- bash -c "if [ -x /root/$1.sh ]; then /root/$1.sh; fi"
fi

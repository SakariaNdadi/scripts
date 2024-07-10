#!/bin/bash

# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Read the ID and VERSION_ID from the os-release file
    . /etc/os-release

    if [ "$ID" == "debian" ]; then
        echo "This is a Debian operating system."
    elif [ "$ID" == "ubuntu" ]; then
        echo "This is an Ubuntu operating system."
    else
        echo "This is not a Debian or Ubuntu operating system."
    fi
else
    echo "/etc/os-release file not found."
    exit 1
fi
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

#!/bin/bash

# Function to get total RAM
get_ram() {
    echo "Total RAM:"
    free -h | grep "Mem:" | awk '{print $2}'
}

# Function to get number of CPU cores
get_cpu_cores() {
    echo "Number of CPU cores:"
    nproc
}

# Function to get CPU speed
get_cpu_speed() {
    echo "CPU Speed:"
    lscpu | grep "MHz" | awk -F ':' '{print $2 " MHz"}' | xargs
}

# Function to get disk space
get_disk_space() {
    echo "Disk Space:"
    df -h --total | grep "total" | awk '{print "Total: " $2 "\nUsed: " $3 "\nAvailable: " $4}'
}

# Function to get all system specifications
get_system_specs() {
    echo "System Specifications:"
    echo "======================"
    get_ram
    echo
    get_cpu_cores
    echo
    get_cpu_speed
    echo
    get_disk_space
}

# Call the function to get all system specifications
get_system_specs

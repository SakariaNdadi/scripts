#!/bin/bash

# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Read the ID and VERSION_ID from the os-release file
    . /etc/os-release

    if [ "$ID" == "debian" ]; then
        if [ "$VERSION_ID" == "12" ]; then
            echo "This is Debian Bookworm 12 (stable)."
        elif [ "$VERSION_ID" == "11" ]; then
            echo "This is Debian Bullseye 11 (oldstable)."
        else
            echo "This is Debian, but version is not compatible with docker."
        fi
    elif [ "$ID" == "ubuntu" ]; then
        if [ "$VERSION_ID" == "24.04" ]; then
            echo "This is Ubuntu Noble 24.04 (LTS)."
        elif [ "$VERSION_ID" == "23.10" ]; then
            echo "This is Ubuntu Mantic 23.10 (EOL: July 12, 2024)."
        elif [ "$VERSION_ID" == "22.04" ]; then
            echo "This is Ubuntu Jammy 22.04 (LTS)."
        elif [ "$VERSION_ID" == "20.04" ]; then
            echo "This is Ubuntu Focal 20.04 (LTS)."
        else
            echo "This is Ubuntu, but version is not compatible with docker."
        fi
    else
        echo "This is not a Debian or Ubuntu operating system."
    fi
else
    echo "/etc/os-release file not found."
    exit 1
fi

# Function to get total RAM
get_ram() {
    total_ram=$(free -m | grep "Mem:" | awk '{print $2}')
    echo "Total RAM: ${total_ram}MB"
    if [ "$total_ram" -lt 2048 ]; then
        echo "Warning: Not enough RAM. Minimum required is 2GB."
    fi
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


# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    echo "Installing Docker on Ubuntu..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker run hello-world
    echo "Docker installed successfully on Ubuntu."
    echo "Testing Docker..."
    sudo docker run hello-world
}

# Function to install Docker on Debian
install_docker_debian() {
    echo "Installing Docker on Debian..."
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker run hello-world
    echo "Docker installed successfully on Debian."
    echo "Testing Docker..."
    sudo docker run hello-world
}

# Function to uninstall Docker
install_docker_ubuntu() {
    echo "Uninstalling Docker..."
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    echo "Docker uninstalled successfully."
}

# Function to get Docker version and manage Docker installation
check_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker is installed."
        docker_version=$(docker --version)
        echo "Docker version: $docker_version"
        read -p "Do you want to uninstall Docker? (y/n): " uninstall_choice
        if [ "$uninstall_choice" == "y" ] || [ "$uninstall_choice" == "Y" ]; then
            uninstall_docker
        else
            echo "Docker will remain installed."
        fi
    else
        echo "Docker is not installed."
        read -p "Do you want to install Docker? (y/n): " install_choice
        if [ "$install_choice" == "y" ] || [ "$install_choice" == "Y" ]; then
            if [ "$ID" == "ubuntu" ]; then
                install_docker_ubuntu
            elif [ "$ID" == "debian" ]; then
                install_docker_debian
            else
                echo "Docker installation is not supported for this operating system."
            fi
        else
            echo "Docker will not be installed."
        fi
    fi
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
    echo
    check_docker
}

# Call the function to get all system specifications
get_system_specs

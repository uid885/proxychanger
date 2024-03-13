#!/bin/bash
# Author      : Christo Deale
# Date	      : 2024-03-13
# proxychanger: Utility to set up proxy configuration on RHEL 9 servers

# Error handling function
handle_error() {
    echo "Error: $1" >&2
    exit 1
}

# Prompt for user input
read -p "Enter your username (name.surname): " username
read -s -p "Enter your password: " password
echo
read -p "Enter the proxy server: " proxy_server
read -p "Enter your domain: " domain

# Validate proxy server address
if ! ping -c 1 -W 1 "$proxy_server" &>/dev/null; then
    handle_error "Proxy server $proxy_server is not reachable."
fi

# Create the proxy configuration string
proxy_config="http://$username:$password@$proxy_server:3128"

# Backup the original yum.conf file
sudo cp /etc/yum.conf /etc/yum.conf.bak || handle_error "Failed to backup yum.conf file."

# Update yum.conf with the proxy configuration
sudo sed -i "1s|^|$proxy_config\n|" /etc/yum.conf || handle_error "Failed to update yum.conf with proxy configuration."

# Set the proxy environment variables system-wide
echo "export http_proxy=$proxy_config" | sudo tee -a /etc/environment >/dev/null
echo "export https_proxy=$proxy_config" | sudo tee -a /etc/environment >/dev/null
echo "export ftp_proxy=$proxy_config" | sudo tee -a /etc/environment >/dev/null
echo "export no_proxy=localhost,127.0.0.1" | sudo tee -a /etc/environment >/dev/null

# Secure handling of password - store it in a file with restricted permissions
echo "$password" > ~/.proxy_password
chmod 600 ~/.proxy_password

echo "Proxy configuration updated successfully!"

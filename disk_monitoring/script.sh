#!/bin/bash

# Run df -h command and filter out the /dev/vda1 filesystem usage percentage
usage=$(df -h | grep '/dev/sda1' | awk 'NR==1{print $5}' | sed 's/%//')
hostname=$(hostname)

# Check if the usage percentage is greater than 65
if [ "$usage" -gt 65 ]; then
    echo "Filesystem usage is over 65 percent. Doing something..."
fi


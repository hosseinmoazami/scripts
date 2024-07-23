#!/bin/bash

# Admins Phone Number
phones=("9123456789")

# Define thresholds
LOAD_THRESHOLD=20
CPU_THRESHOLD=70
RAM_THRESHOLD=70
hostname=$(hostname)

# Get the 5-minute load average
LOAD_AVG=$(awk '{print $2}' /proc/loadavg)

# Get CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Get RAM usage
MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100.0}')

# Notification, Method: SMS
send_sms() {
        for phone in ${phones[@]}; do
                echo "Send SMS To $phone, With message $1"
        done
}

# Check the load average
if (($(echo "$LOAD_AVG > $LOAD_THRESHOLD" | bc -l))); then
        send_sms "Server: ${hostname}, Warning: 1-minute load average is over $LOAD_THRESHOLD"
fi

# Check the CPU usage
if (($(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l))); then
        send_sms "Server: ${hostname}, Warning: CPU usage is over $CPU_THRESHOLD%"
fi

# Check the RAM usage
if (($(echo "$MEMORY_USAGE > $RAM_THRESHOLD" | bc -l))); then
        send_sms "Server: ${hostname}, Warning: RAM usage is over $RAM_THRESHOLD%"
fi

#!/bin/bash

## Strict mode
set -eou pipefail

## Path for cron safety
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

## Defining log file
logfile=/var/log/server_health_report/server_health_report.log

exec >> $logfile 2>&1

echo "============================== $(date '+%F %T') =============================="

## Logging function
log(){
        echo "$(date '+%F %T' ) - $1"
}

## Critical Flag
critical_flag=0

## Function for Disk usage
disk_usage(){
log "Checking Disk Usage...................."
root_size=$(df -h / | awk 'NR==2 {print $2}')
root_uti=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)
root_used=$(df -h / | awk 'NR==2 {print $3}')
root_available=$(df -h / | awk 'NR==2 {print $4}')
boot_uti=$(df -h /boot | awk 'NR==2 {print $5}' | cut -d% -f1)
boot_used=$(df -h /boot | awk 'NR==2 {print $3}')
boot_avail=$(df -h /boot | awk 'NR==2 {print $4}')
boot_size=$(df -h /boot | awk 'NR==2 {print $2}')

if [[ $root_uti -gt 80 ]]
then
	log "Critical: Root usage is $root_uti%"
	critical_flag=1
else
	log "Normal: Root usage is $root_uti%"
fi

if [[ $boot_uti -gt 80 ]]
then
	log "Critical: Boot usage is $boot_uti%"
	critical_flag=1
else
	log "Normal: Boot usage is $boot_uti%"
fi

log "root_size: $root_size  used: $root_used  available: $root_available"
log "boot_size: $boot_size  used: $boot_used  available: $boot_avail"
}


## Function for Memory usage
memory_usage(){
log "Checking Memory Usage...................."
mem_total=$(cat /proc/meminfo | awk '/MemTotal/{print $2}')
mem_avail=$(cat /proc/meminfo | awk '/MemAvailable/{print $2}')
mem_free=$(cat /proc/meminfo | awk '/MemFree/{print $2}')
mem_total_free=$(($mem_avail+$mem_free))
mem_used=$(($mem_total-$mem_total_free))
mem_free_per=$(($mem_total_free*100/$mem_total))
mem_used_per=$(($mem_used*100/$mem_total))

if [[ $mem_used_per -gt 80 ]]
then
	log "Critical: Memory usage is $mem_used_per%"
	critical_flag=1
else
	log "Normal: Memory usage is $mem_used_per%"
fi

log "mem_total: $mem_total KB  used: $mem_used KB  available: $mem_avail KB"
}

## Function for Swap usage
swap_usage(){
log "Checking swap Usage...................."
swap_total=$(cat /proc/meminfo | awk '/SwapTotal/{print $2}')
swap_free=$(cat /proc/meminfo | awk '/SwapFree/{print $2}')
swap_used=$(($swap_total-$swap_free))
swap_used_percentage=$(($swap_used*100/$swap_total))

if [[ $swap_used_percentage -gt 80 ]]
then
	log "Critical: Swap usage is $swap_used_percentage%"
	critical_flag=1
else
	log "Normal: Swap usage is $swap_used_percentage%"
fi
}

disk_usage
memory_usage

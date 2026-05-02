#!/bin/bash

## Strict mode
set -euo pipefail

## Path for cron safety
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

## Defining log file

logfile=/var/log/server_health_report/server_health_report.log
logdir=/var/log/server_health_report/

## Function for Log Directory validation
log_dir_validation(){
if [[ -d $logdir ]]
then
	log_file_size=$(du -s /var/log/server_health_report/server_health_report.log | awk '{print $1}')
	log "OK : Log file size is $log_file_size KB."
else
	log "Creating log directory............................"
	mkdir -p $logdir
	log "Log directory created............................."
fi
}

## Function for Log Rotation
log_rotation(){
if [[ $log_file_size -gt 1048576 ]]
then
	> "$logfile"
	log "OK: Log rotation completed."
else

	log "OK : Log size is normal no need for rotation."
fi
}

exec >> "$logfile" 2>&1

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
root_info=$(df -h / | awk 'NR==2')
root_size=$(echo $root_info | awk '{print $2}')
root_uti=$(echo $root_info | awk '{print $5}' | cut -d% -f1)
root_used=$(echo $root_info | awk '{print $3}')
root_available=$(echo $root_info | awk '{print $4}')
boot_info=$(df -h /boot | awk 'NR==2')
boot_uti=$(echo $boot_info | awk '{print $5}' | cut -d% -f1)
boot_used=$(echo $boot_info | awk '{print $3}')
boot_avail=$(echo $boot_info | awk '{print $4}')
boot_size=$(echo $boot_info | awk '{print $2}')

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

if [[ $swap_total -eq 0 ]]
then
	log "No swap cofigured"
	return
fi

if [[ $swap_used_percentage -gt 80 ]]
then
	log "Critical: Swap usage is $swap_used_percentage%"
	critical_flag=1
else
	log "Normal: Swap usage is $swap_used_percentage%"
fi

log "swap_total : $swap_total KB  used : $swap_used KB  available: $swap_free KB"
}

## Function for CPU usage
cpu_usage(){
log "Checking cpu Usage...................."

##mpstat Command validation
command -v mpstat > /dev/null || {
log "mpstat command not installed."
return
}

cpu_idle=$(mpstat | awk 'NR==4 {print $NF}'| cut -d. -f1)
cpu_used=$(( 100 - $cpu_idle ))
if [[ $cpu_used -gt 80 ]]
then
	log "Critical: CPU usage is $cpu_used%"
	critical_flag=1
else
	log "Normal: CPU usage is $cpu_used%"
fi

log "CPU USED : $cpu_used% CPU FREE : $cpu_idle%"
}

## Function for Load average
load_average(){
log "Checking Load average...................."
load_avg=$(cat /proc/loadavg | awk '{print $1}' | cut -d. -f1)
cpu_count=$(nproc)
if [[ $load_avg > $cpu_count ]]
then
	log "Critical: Load average is $load_avg"
	critical_flag=1
else
	log "Normal: Load average is $load_avg"
fi
}

## Function for Top processes
top_processes(){
log "Checking Top processes...................."
ps -eo pid,ppid,stat,comm,%cpu,%mem --sort -%cpu | head -n 5
echo
ps -eo pid,ppid,stat,comm,%cpu,%mem --sort -%mem | head -n 5

}

main(){
log_dir_validation
log_rotation
disk_usage
memory_usage
swap_usage
cpu_usage
load_average
top_processes

if [[ $critical_flag == 1 ]]
then
	log "FINAL STATUS: CRITICAL"
	exit 1
else
	log "FINAL STATUS: OK"
	exit 0
fi
}
main

#using while and case with "getopts" option to make script work with
#providing arguments

while getopts "hdcmsa" opt;do
	case $opt in
		d)
		  disk_usage
		  ;;
		c)
		  cpu_usage
	          ;;
		m)
		  memory_usage
		  ;;
		s)
		  swap_usage
		  ;;
		a)
		  disk_usage
		  cpu_usage
		  memory_usage
		  swap_usage
		  load_average
		  top_processes
		  ;;
		h)
		  echo "Usage: ./server_health_2.sh -d[disk],c[cpu],m[memory],s[swap],a[all]"
		  exit 0
		  ;;
		*)
		  echo "Invalid Option"
                  exit 1
		  ;;

	esac
done

#!/bin/bash
set -euo pipefail
echo
echo "####################################################"
echo "Log file is saved at '/var/log/'"
echo "####################################################"
logfile=/var/log/server_health_$(date '+%d-%m-%Y_%H:%M:%S').txt
exec >> "$logfile" 2>&1

root_uti=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)
root_used=$(df -h / | awk 'NR==2 {print $3}')
root_avail=$(df -h / | awk 'NR==2 {print $4}')
root_size=$(df -h / | awk 'NR==2 {print $2}')
boot_uti=$(df -h /boot | awk 'NR==2 {print $5}' | cut -d% -f1)
boot_used=$(df -h /boot | awk 'NR==2 {print $3}')
boot_avail=$(df -h /boot | awk 'NR==2 {print $4}')
boot_size=$(df -h /boot | awk 'NR==2 {print $2}')
memory_total=$(free -m | awk 'NR==2{ print $2}')
memory_used=$(free -m | awk 'NR==2{ print $3}')
memory_avail=$(free -m | awk 'NR==2{ print $7}')
memory_free=$(free -m | awk 'NR==2{ print $4}')
mb_convert=1024

echo
echo "Server health report of $(date)"
echo "####################################################"
echo "Root partition usage"
echo "####################################################"
echo
if [[ $root_uti -gt 80 ]]
then
        echo "Root size is critical"
        echo "Root partition is $root_uti% utilized"
        echo "Root partition size:$root_size"
        echo "Root partition used space:$root_used"
        echo "Root partition Available space:$root_avail"
	echo
else
        echo "Root size is Normal"
        echo "Root partition is $root_uti% utilized"
        echo "Root partition size:$root_size"
        echo "Root partition used space:$root_used"
        echo "Root partition Available space:$root_avail"
	echo
fi

echo "####################################################"
echo "Boot partition usage"
echo "####################################################"
echo
if [[ $boot_uti -gt 80 ]]
then
        echo "Boot size is critical"
        echo "Boot partition is $boot_uti% utilized"
        echo "Boot partition size:$boot_size"
        echo "Boot partition used space:$boot_used"
        echo "Boot partition Available space:$boot_avail"
else
        echo "Boot size is Normal"
        echo "Boot partition is $boot_uti% utilized"
        echo "Boot partition size:$boot_size"
        echo "Boot partition used space:$boot_used"
        echo "Boot partition Available space:$boot_avail"
	echo
fi

echo "####################################################"
echo "Memory usage in MB"
echo "####################################################"
echo

mem_total=$(cat /proc/meminfo | awk '/MemTotal/{print $2}')
mem_avail=$(cat /proc/meminfo | awk '/MemAvailable/{print $2}')
mem_free=$(cat /proc/meminfo | awk '/MemFree/{print $2}')
mem_total_free=$(($mem_avail+$mem_free))
mem_used=$(($mem_total-$mem_total_free))
mem_free_per=$(($mem_total_free*100/$mem_total))
threshold=20

if [[ $mem_free_per -le $threshold ]]
then
        echo "Memory usage is Critical"
	echo "Memory size is:$(($mem_total/$mb_convert))"
        echo "Used Memory is:$(($mem_used/$mb_convert))"
        echo "Available Memory is:$(($mem_avail/$mb_convert))"
        echo "Free memory is:$(($mem_free/$mb_convert))"
	echo "Total free memory is:$(($mem_total_free/$mb_convert))"
	echo
else
        echo "Memory usage is Normal"
	echo "Memory size is:$(($mem_total/$mb_convert))"
        echo "Used Memory is:$(($mem_used/$mb_convert))"
        echo "Available Memory is:$(($mem_avail/$mb_convert))"
        echo "Free memory is:$(($mem_free/$mb_convert))"
        echo "Total free memory is:$(($mem_total_free/$mb_convert))"
	echo
fi

echo "####################################################"
echo "Swap usage in MB"
echo "####################################################"
echo
swap_total=$(cat /proc/meminfo | awk '/SwapTotal/{print $2}')
swap_free=$(cat /proc/meminfo | awk '/SwapFree/{print $2}')
swap_used=$(($swap_total-$swap_free))
swap_free_percentage=$(($swap_free*100/$swap_total))
if [[ $swap_free_percentage -le $threshold ]]
then
	echo "Swap usage is Critical"
	echo "Swap size is:$(($swap_total/1024))"
	echo "Used Swap is:$(($swap_used/1024))"
	echo "Free Swap is:$(($swap_free/1024))"
	echo
else
	echo "Swap usage is Normal"
        echo "Swap size is:$(($swap_total/1024))"
        echo "Used Swap is:$(($swap_used/1024))"
        echo "Free Swap is:$(($swap_free/1024))"
	echo
fi

echo "####################################################"
echo "CPU usage"
echo "####################################################"
echo

cpu_used=$(mpstat | awk 'NR==4 {print 100-$13}' | cut -d. -f1)
cpu_idle=$(mpstat | awk 'NR==4 {print $13}' | cut -d. -f1)

if [[ $cpu_idle -le 20 ]]
then
	echo "Cpu usage is Critical"
        echo "Used Cpu is:$cpu_used%"
        echo "Idle Cpu is:$cpu_idle%"
        echo
else
	echo "Cpu usage is Normal"
        echo "Used Cpu is:$cpu_used%"
        echo "Idle Cpu is:$cpu_idle%"
        echo
fi

echo "####################################################"
echo "Cpu Load Average"
echo "####################################################"
echo

#load_avg1m=$(top -bn1 | grep "load average:" | awk '{print $10}' | cut -d. -f1)
#load_avg5m=$(top -bn1 | grep "load average:" | awk '{print $11}' | cut -d. -f1)
#load_avg15m=$(top -bn1 | grep "load average:" | awk '{print $12}' | cut -d. -f1)
load_avg1m=$(uptime | awk -F 'load average:' '{print $2}' | awk -F, '{print $1}' | cut -d. -f1)
load_avg5m=$(uptime | awk -F 'load average:' '{print $2}' | awk -F, '{print $2}' | cut -d. -f1)
load_avg15m=$(uptime | awk -F 'load average:' '{print $2}' | awk -F, '{print $3}'| cut -d. -f1)
cpu_count=$(nproc)

if [[ $load_avg1m -ge $cpu_count ]]
then
	echo "1min Load AVG is Critical"
        echo "1min Load AVG is:$load_avg1m"
        echo "5min Load AVG is:$load_avg5m"
        echo "15min Load AVG is:$load_avg15m"
        echo
else
	echo "1min Load AVG is Normal"
        echo "1min Load AVG is:$load_avg1m"
        echo "5min Load AVG is:$load_avg5m"
        echo "5min Load AVG is:$load_avg15m"
        echo
fi

top_cpu_p=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 5)
top_mem_p=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 5)

echo "####################################################"
echo "Top 5 Cpu and Menmory consuming processes"
echo "####################################################"
echo
echo "Total Running processes are:$(ps -aux | wc -l)"
echo
echo "Top 5 Cpu consuming processes->"
echo "$top_cpu_p"
echo
echo "Top 5 Memory consuming processes->"
echo "$top_mem_p"


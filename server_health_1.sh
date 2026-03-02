#!/bin/bash
#declare -A myarray
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
echo "Memory usage"
echo "####################################################"
echo
if [[ $memory_avail -le 200 ]]
then
        echo "Memory usage is Critical"
        echo "Memory size is:$memory_total"
        echo "Used Memory is:$memory_used"
        echo "Available Memory is:$memory_avail"
        echo "Free memory is:$memory_free"
	echo
else
        echo "Memory usage is Normal"
        echo "Memory size is:$memory_total"
        echo "Used Memory is:$memory_used"
        echo "Available Memory is:$memory_avail"
        echo "Free memory is:$memory_free"
	echo
fi

echo "####################################################"
echo "Swap usage"
echo "####################################################"
echo
swap_total=$(free -m | awk 'NR==3{ print $2}')
swap_used=$(free -m | awk 'NR==3{ print $3}')
swap_free=$(free -m | awk 'NR==3{ print $4}')
if [[ $swap_free -le 1024 ]]
then
	echo "Swap usage is Critical"
        echo "Swap size is:$swap_total"
        echo "Used Swap is:$swap_used"
        echo "Free Swap is:$swap_free"
	echo
else
	echo "Swap usage is Normal"
        echo "Swap size is:$swap_total"
        echo "Used Swap is:$swap_used"
        echo "Free Swap is:$swap_free"
	echo
fi

echo "####################################################"
echo "CPU usage"
echo "####################################################"
echo

cpu_used=$(top -bn1 | grep "%Cpu(s)" | awk -F[:,] '{print 100-$5}')
cpu_idle=$(top -bn1 | grep "%Cpu(s)" | awk '{print $8}' | cut -d. -f1)

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

if [[ $load_avg1m -ge 2 ]]
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


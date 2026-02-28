#!/bin/bash
#declare -A myarray
root_uti=$(df -hT | awk 'NR==6 {print $6}' | awk -F% '{print $1}')
root_used=$(df -hT | awk 'NR==6 {print $4}')
root_avail=$(df -hT | awk 'NR==6 {print $5}')
root_size=$(df -hT | awk 'NR==6{print $3}')
boot_uti=$(df -hT | awk 'NR==7 {print $6}' | awk -F% '{print $1}')
boot_used=$(df -hT | awk 'NR==7 {print $4}')
boot_avail=$(df -hT | awk 'NR==7 {print $5}')
boot_size=$(df -hT | awk 'NR==7{print $3}')
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

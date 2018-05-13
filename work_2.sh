#!/bin/bash

#Student Name: Yash Karan Singh
#Student Number : 10445116


echo "-------------------System Report-------------------"

date=$(date +%d/%m/%Y)
time=$(date +%H:%M:%S)
hostname=$(hostname)

printf "Date: %s Time: %s \t Host Name %s \n" $date $time $hostname
echo "---------------------------------------------------"

#The snipped below for uptime and the logic behind it is referred from stackoverflow.com 
uptime | awk -F'( |,|:)+' '{if ($7=="min") 
				m=$6; 
			    else {if ($7~/^day/) 
					{d=$6;h=$8;m=$9} 
				  else 
					{h=$6;m=$7}
				 }
			    } 
			    {print d+0,"days,",h+0,"hours,",m+0,"minutes."}'

printf "\n"

printf "Current Users: "
echo who|wc -l

top -bn1 | grep "KiB Mem" | awk '{printf "Memory Utilisation: %d%%",($(NF-3)/$(NF-7))*100}'
printf "\n"
#top -bn1 | grep "load" | awk '{printf "CPU Load %.2f",$(NF-2)}'

uptime | awk '{printf "CPU Load: %.2f", $(NF)}' #for CPU-LOAD, the 15 min average cpu load has been taken from uptime.

printf "\n"
echo "---------------------------------------------------"

exit 0

#www.stackoverflow.com/questions/28353409/bash-format-to-show-days-hours-minutes
#!/bin/bash
# Script to fetch top 10 processes by MEM usage and output in InfluxDB Line Protocol

# Get top 10 processes by MEM usage, skipping header
processes=$(ps -eo user,pid,%cpu,%mem --sort=-%mem | tail -n +2 )

filtered_processes=$(echo "$processes" | awk '$4 > 0.1')

# Check if filtered_processes is empty
if [ -z "$filtered_processes" ]; then
  exit 0
fi

# Loop through each process and format as InfluxDB Line Protocol
while IFS= read -r line; do

  user=$(echo "$line" | awk '{print $1}' )
  pid=$(echo "$line" | awk '{print $2}')
  cpu_usage=$(echo "$line" | awk '{print $3}')
  mem_usage=$(echo "$line" | awk '{print $4}')
  # Get full command from /proc/<pid>/cmdline
  if [ -r "/proc/$pid/cmdline" ]; then
    command=$(tr '\0' ' ' < "/proc/$pid/cmdline" |  sed 's/"/\\"/g' | sed 's/[[:space:]]*$//' | sed 's/.*/"&"/')
  else
    command="\"unknown\""
  fi

  # Skip invalid or empty lines
  if [ -z "$user" ] || [ -z "$pid" ] || [ -z "$command" ] || [ -z "$cpu_usage" ] || [ -z "$mem_usage" ]  ; then
    continue
  fi

  # Output in InfluxDB Line Protocol
  echo "top_processes,user=$user pid=${pid}u,command=${command},cpu_usage=$cpu_usage,mem_usage=$mem_usage "
done <<< "$filtered_processes"

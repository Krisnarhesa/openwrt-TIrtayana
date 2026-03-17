#!/bin/bash
SHOW_IP_PATTERN="^[ewr].*|^br.*|^lt.*|^umts.*"

function display() {
    if [[ -n "${2}" && "${2}" > "0" ]]; then
        printf "%-5s%s" "${1}:"
        if awk "BEGIN{exit ! (${2} > ${3})}"; then
            echo -ne "\e[0;91m ${2}"
        else
            echo -ne "\e[0;92m ${2}"
        fi
        printf "%-1s%s\x1B[0m" "${5}"
        printf "%-9s%s\t" "${6}"
    fi
}

function get_ip_addresses() {
    local ips=()
    for f in /sys/class/net/*; do
        local intf=$(basename ${f})
        if [[ ${intf} =~ ${SHOW_IP_PATTERN} ]]; then
            local tmp=$(ip -4 addr show dev ${intf} 2>/dev/null | awk '/inet/ {print $2}' | cut -d'/' -f1)
            [[ -n "${tmp}" ]] && ips+=("${tmp}")
        fi
    done
    echo "${ips[@]}"
}

ip_address="$(get_ip_addresses)"

# Uptime
UptimeString=$(uptime | tr -d ',')
time="$(awk -F"up " '{print $2}' <<< "${UptimeString}" | awk -F", " '{print $1}')"
load="$(awk -F"average: " '{print $2}' <<< "${UptimeString}")"

# Memory
mem_info="$(LC_ALL=C free -w 2>/dev/null | grep "^Mem" || LC_ALL=C free | grep "^Mem")"
memory_usage="$(awk '{printf("%.0f",(($2-($4+$6))/$2)*100)}' <<< ${mem_info})"
memory_total="$(awk '{printf("%d",$2/1024)}' <<< ${mem_info})"

# Swap
swap_info="$(free -m | tail -1)"
swap_usage="$(awk '{if($2>0) printf("%d",$3/$2*100); else print 0}' <<< ${swap_info})"
swap_total="$(awk '{printf("%d",$2/1024)}' <<< ${swap_info})"

# CPU Temp
if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
    cpu_temp="$(awk '{printf("%.1f", $0/1000)}' /sys/class/thermal/thermal_zone0/temp)"
elif [[ -f "/sys/class/hwmon/hwmon0/temp1_input" ]]; then
    cpu_temp="$(awk '{printf("%.1f", $0/1000)}' /sys/class/hwmon/hwmon0/temp1_input)"
else
    cpu_temp="N/A"
fi

# Architecture
arch="$(uname -m) ($(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs || echo 'ARMv8'))"

# Storage
RootInfo="$(df -h /)"
root_usage="$(awk '/\// {print $(NF-1)}' <<< "${RootInfo}" | tail -1 | sed 's/%//g')"
root_total="$(awk '/\// {print $(NF-4)}' <<< "${RootInfo}" | tail -1)"

BootInfo="$(df -h /boot 2>/dev/null)"
boot_usage="$(awk '/\// {print $(NF-1)}' <<< "${BootInfo}" | tail -1 | sed 's/%//g')"
boot_total="$(awk '/\// {print $(NF-4)}' <<< "${BootInfo}" | tail -1)"

critical_load="$((1 + $(grep -c processor /proc/cpuinfo) / 2))"
machine_model="$(cat /proc/device-tree/model 2>/dev/null | tr -d '\000' || echo 'Unknown')"

printf " Device Model: \x1B[93m%s\x1B[0m\n" "${machine_model}"
printf " Architecture: \x1B[93m%s\x1B[0m\n" "${arch}"
display " Load Average" "${load%% *}" "${critical_load}" "0" "" "${load#* }"
printf "Uptime: \x1B[92m%s\x1B[0m\n" "${time}"
display " Ambient Temp" "${cpu_temp}" "80" "0" "" "°C"
echo ""
display " Memory Usage" "${memory_usage}" "70" "0" "%" " of ${memory_total}M"
display "Swap Usage" "${swap_usage}" "80" "0" "%" " of ${swap_total}M"
echo ""
display " Boot Storage" "${boot_usage}" "90" "1" "%" " of ${boot_total}"
display "ROOTFS" "${root_usage}" "90" "1" "%" " of ${root_total}"
echo ""
[[ -n "${ip_address}" ]] && printf " IP Addr: \x1B[92m%s\x1B[0m\n" "${ip_address}"
echo "───────────────────────────────────────────────────────────────────────"

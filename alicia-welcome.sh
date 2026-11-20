#!/bin/bash
[ -n "${BASH_VERSION:-}" ] || return 0 2>/dev/null || exit 0
[ -t 1 ] || return 0 2>/dev/null || exit 0

_alicia_bytes() {
    awk -v b="$1" 'BEGIN {
        if (b >= 1073741824) printf "%.1f GiB", b / 1073741824;
        else                 printf "%.0f MiB", b / 1048576;
    }'
}

_alicia_mem() {
    local used="" limit="" host
    host=$(awk '/^MemTotal:/ {print $2 * 1024}' /proc/meminfo 2>/dev/null)

    if [ -r /sys/fs/cgroup/memory.max ]; then
        limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null)
        used=$(cat /sys/fs/cgroup/memory.current 2>/dev/null)
    elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
        limit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null)
        used=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null)
    fi

    case "$limit" in ''|*[!0-9]*) limit="" ;; esac
    case "$used"  in ''|*[!0-9]*) used=""  ;; esac

    if [ -z "$limit" ] || [ -z "$used" ] || { [ -n "$host" ] && [ "$limit" -gt "$host" ]; }; then
        limit="$host"
        used=$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print (t - a) * 1024}' /proc/meminfo 2>/dev/null)
    fi

    if [ -n "$limit" ] && [ -n "$used" ]; then
        printf '%s / %s' "$(_alicia_bytes "$used")" "$(_alicia_bytes "$limit")"
    else
        printf 'N/A'
    fi
}

_alicia_row() { 
    printf '  %s%-11s%s│%s %s%s%s\n' "$C_PINK" "$1" "$C_GREY" "$C_RESET" "${3:-$C_WHITE}" "$2" "$C_RESET"
}

C_RESET=$'\e[0m';  C_BOLD=$'\e[1m'
C_PINK=$'\e[38;5;213m'; C_WHITE=$'\e[38;5;255m'; C_GREY=$'\e[38;5;245m'
C_GREEN=$'\e[38;5;84m'; C_YELLOW=$'\e[38;5;222m'

_os=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}")
_host=$(hostname 2>/dev/null || echo unknown)
_user=$(whoami 2>/dev/null || echo unknown)
_up=$(uptime -p 2>/dev/null | sed 's/^up //')
_cpu=$(nproc 2>/dev/null || echo N/A)
_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
_disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}')
_node=$(node -v 2>/dev/null || echo "tidak terpasang")
_pm2=$(pm2 -v 2>/dev/null || echo "tidak terpasang")
_now=$(date '+%d %b %Y, %H:%M:%S %Z' 2>/dev/null)

_art=(
"     █████╗ ██╗     ██╗ ██████╗██╗ █████╗ "
"    ██╔══██╗██║     ██║██╔════╝██║██╔══██╗"
"    ███████║██║     ██║██║     ██║███████║"
"    ██╔══██║██║     ██║██║     ██║██╔══██║"
"    ██║  ██║███████╗██║╚██████╗██║██║  ██║"
"    ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝╚═╝╚═╝  ╚═╝"
)
_grad=(219 213 207 171 135 99)

printf '\n'
for _i in "${!_art[@]}"; do
    printf '%s%s%s\n' "${C_BOLD}"$'\e[38;5;'"${_grad[$_i]}"'m' "${_art[$_i]}" "$C_RESET"
done
printf '\n'
printf '%s\n' "${C_WHITE}${C_BOLD}               A L I C I A - V P S${C_RESET}"
printf '%s\n' "${C_YELLOW}        Cepat · Aman · Siap Dipakai${C_RESET}"
printf '\n%s\n\n' "${C_GREY}  ════════════════════════════════════════════${C_RESET}"

printf '  %s%sINFO SISTEM%s\n\n' "$C_PINK" "$C_BOLD" "$C_RESET"
_alicia_row "User"      "$_user"
_alicia_row "Hostname"  "$_host"
_alicia_row "OS"        "$_os"
_alicia_row "Uptime"    "${_up:-N/A}"
_alicia_row "RAM"       "$(_alicia_mem)"
_alicia_row "Disk"      "${_disk:-N/A}"
_alicia_row "CPU Core"  "$_cpu"
_alicia_row "IP"        "${_ip:-N/A}"

printf '\n  %s%sLINGKUNGAN DEV%s\n\n' "$C_PINK" "$C_BOLD" "$C_RESET"
_alicia_row "Node.js"   "$_node" "$C_GREEN"
_alicia_row "PM2"       "$_pm2"  "$C_GREEN"

printf '\n%s\n\n' "${C_GREY}  ════════════════════════════════════════════${C_RESET}"
_alicia_row "Login"     "$_now"

printf '\n  %s➜%s %sProses PM2%s  : %spm2 list%s\n'   "$C_GREEN" "$C_RESET" "$C_WHITE" "$C_GREY" "$C_YELLOW" "$C_RESET"
printf '  %s➜%s %sMonitor%s     : %shtop%s\n'         "$C_GREEN" "$C_RESET" "$C_WHITE" "$C_GREY" "$C_YELLOW" "$C_RESET"
printf '  %s➜%s %sInfo sistem%s : %sneofetch%s\n'     "$C_GREEN" "$C_RESET" "$C_WHITE" "$C_GREY" "$C_YELLOW" "$C_RESET"

printf '\n  %sBantuan : https://t.me/akuTonyStark%s\n'  "$C_GREY" "$C_RESET"
printf '  %sChannel : https://t.me/aboutAlicia%s\n\n'   "$C_GREY" "$C_RESET"

unset -f _alicia_bytes _alicia_mem _alicia_row
unset _os _host _user _up _cpu _ip _disk _node _pm2 _now _art _grad _i \
      C_RESET C_BOLD C_PINK C_WHITE C_GREY C_GREEN C_YELLOW

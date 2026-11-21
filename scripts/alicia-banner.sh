#!/bin/bash
# Alicia-VPS | banner login (hanya untuk sesi interaktif)
[ -t 1 ] || return 0 2>/dev/null || exit 0

R=$'\e[0m'; B=$'\e[1m'
CY=$'\e[38;5;45m'; MG=$'\e[38;5;213m'; GR=$'\e[38;5;82m'
YL=$'\e[38;5;221m'; DM=$'\e[38;5;244m'; WH=$'\e[38;5;255m'

# Info sistem
os=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}")
mem=$(free -h 2>/dev/null | awk '/^Mem:/{print $3" / "$2}')
up=$(uptime -p 2>/dev/null | sed 's/^up //')
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
disk=$(df -h / 2>/dev/null | awk 'NR==2{print $3" / "$2" ("$5")"}')
if pgrep -f 'God Daemon' >/dev/null 2>&1; then
    apps=$(pm2 jlist 2>/dev/null | node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{try{const l=JSON.parse(d.slice(d.indexOf("[")));console.log(l.filter(p=>p.pm2_env.status==="online").length+" online / "+l.length+" total")}catch(e){console.log("0 online / 0 total")}})' 2>/dev/null)
fi
nodev=$(node -v 2>/dev/null || echo "-")
pm2v=$(pm2 -v 2>/dev/null || echo "-")

row() { printf "  %s%-10s%s %s:%s %s%s%s\n" "$CY" "$1" "$R" "$DM" "$R" "$2" "$3" "$R"; }
line() { printf "\n"; }

printf '\n%s%s' "$MG" "$B"
cat <<'ART'
     █████╗ ██╗     ██╗ ██████╗██╗ █████╗
    ██╔══██╗██║     ██║██╔════╝██║██╔══██╗
    ███████║██║     ██║██║     ██║███████║
    ██╔══██║██║     ██║██║     ██║██╔══██║
    ██║  ██║███████╗██║╚██████╗██║██║  ██║
    ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝╚═╝╚═╝  ╚═╝
ART
printf '%s\n' "$R"
printf '        %s%sAlicia-VPS%s  %s·  Fast · Safe · Spacious%s\n\n' "$WH" "$B" "$R" "$YL" "$R"

line
row "User"     "$WH" "$(whoami)"
row "Hostname" "$WH" "$(hostname)"
row "OS"       "$WH" "$os"
row "Uptime"   "$WH" "${up:-N/A}"
row "Memory"   "$WH" "${mem:-N/A}"
row "Disk"     "$WH" "${disk:-N/A}"
row "CPU"      "$WH" "$(nproc 2>/dev/null || echo N/A) core"
row "IP"       "$WH" "${ip:-N/A}"
line
row "Node.js"  "$GR" "$nodev"
row "PM2"      "$GR" "$pm2v"
row "PM2 Apps" "$GR" "${apps:-0 online / 0 total}"
line
row "Login"    "$WH" "$(date '+%d %b %Y · %H:%M:%S')"

printf '\n  %s>%s %-14s %s%s%s\n' "$GR" "$R" "Proses PM2" "$YL" "pm2 list" "$R"
printf   '  %s>%s %-14s %s%s%s\n' "$GR" "$R" "Monitor"    "$YL" "htop" "$R"
printf '\n  %sAlicia-VPS Infrastructure%s\n\n' "$DM" "$R"

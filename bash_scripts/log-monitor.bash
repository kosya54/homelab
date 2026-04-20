#!/usr/bin/env bash
#Проверяет суммарное колличество ERROR и CRITICAL в journalctl,
#если значение превышает $LIMIT,
#то записывает в лог $LOG_FILE и отправляет сообщение в wall.

set -euo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

LOG_FILE="/var/log/log-monitor.log"
LOCK_FILE="/tmp/.log-monitor.lock"

LIMIT=${1:-10}
UNIT=${2:-nginx}
DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')

exec 200>"$LOCK_FILE"
flock -n 200 || { echo "[$DATE_NOW] - Скрипт уже исполняется. Выход." >> "$LOG_FILE"; exit 0; }

send_message() {
    echo "$MSG" | wall
}

write_log() {
    echo "$MSG" >> "$LOG_FILE"
}

ERR_WARN_COUNT=$(journalctl --unit "$UNIT" --since "1 hour ago" -p err..crit --no-pager --quiet | wc -l)
MSG="[$DATE_NOW] - Превышено пороговое значение ($LIMIT) для $UNIT: $ERR_WARN_COUNT"

if [ "$ERR_WARN_COUNT" -gt "$LIMIT" ]; then
    write_log
    send_message
fi
#Вывод колличества попыток и адресов, с которых пытались подключиться за последние 24 часа по ssh
( echo "COUNT IP_ADDRESS"; sudo journalctl --since "24 hour ago" -t sshd \
    | grep -i "failed password" | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn ) | column -t

#Вывод топ 10 процессов по уровням до warning за 12 часов
( echo "COUNT PROC"; sudo journalctl --since "12 hour ago" --no-pager -p warning \
    | awk '{print $5}' | cut -d'[' -f1 | sort | uniq -c | sort -rn | head -n 10 ) | column -t

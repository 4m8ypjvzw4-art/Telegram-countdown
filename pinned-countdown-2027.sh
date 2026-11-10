
#!/usr/bin/env bash
set -euo pipefail

# Countdown to 18 September 2027, Moscow time
TARGET_DATE="2027-09-18"
TODAY=$(TZ=Europe/Moscow date +%F)

TODAY_TS=$(TZ=Europe/Moscow date -d "$TODAY" +%s)
TARGET_TS=$(TZ=Europe/Moscow date -d "$TARGET_DATE" +%s)

DAYS=$(( (TARGET_TS - TODAY_TS) / 86400 ))
if (( DAYS < 0 )); then DAYS=0; fi

if (( DAYS % 10 == 1 && DAYS % 100 != 11 )); then
  WORD="день"
elif (( DAYS % 10 >= 2 && DAYS % 10 <= 4 &&
        (DAYS % 100 < 12 || DAYS % 100 > 14) )); then
  WORD="дня"
else
  WORD="дней"
fi

TEXT="📅 До 18 сентября 2027 года осталось: $DAYS $WORD"

API="https://api.telegram.org/bot${BOT_TOKEN}"

# ID of the message pinned in the new group
: "${MESSAGE_ID:?Set MESSAGE_ID before running}"
: "${CHAT_ID:?Set CHAT_ID before running}"

RESPONSE=$(curl -fsS -X POST "${API}/editMessageText" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "message_id=${MESSAGE_ID}" \
  --data-urlencode "text=${TEXT}")

echo "$RESPONSE" | jq -e '.ok == true' >/dev/null
echo "Countdown updated: $DAYS $WORD"


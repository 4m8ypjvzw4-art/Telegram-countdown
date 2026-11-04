#!/bin/bash
set -e

IMG="banner.jpg"
OUT="output.jpg"

# Progress calculation

TODAY=$(TZ=Europe/Moscow date -d "$(TZ=Europe/Moscow date +%F)" +%s)
START_TIMESTAMP=$(TZ=Europe/Moscow date -d "$START_DATE" +%s)
TARGET_TIMESTAMP=$(TZ=Europe/Moscow date -d "$TARGET_DATE" +%s)

TOTAL=$(( (TARGET_TIMESTAMP - START_TIMESTAMP) / 86400 ))

LEFT=$(( (TARGET_TIMESTAMP - TODAY) / 86400 ))


if [ "$TOTAL" -le 0 ]; then
  echo "ERROR: Invalid date range"
  exit 1
fi

if [ "$LEFT" -lt 0 ]; then LEFT=0; fi
if [ "$LEFT" -gt "$TOTAL" ]; then LEFT=$TOTAL; fi

DAYS_DONE=$(( TOTAL - LEFT ))
PERCENT=$(( 100 * DAYS_DONE / TOTAL ))


echo "Progress: $DAYS_DONE/$TOTAL days ($PERCENT%)"

# Image size
HEIGHT=$(identify -format "%h" "$IMG")
WIDTH=$(identify -format "%w" "$IMG")

# Split point (in pixels)
COLOR_HEIGHT=$(( HEIGHT * PERCENT / 100 ))

# Process image
convert "$IMG" \
  -gravity North -crop "${WIDTH}x$(( HEIGHT - COLOR_HEIGHT ))+0+0" +repage \
  -colorspace Gray "top.jpg"

convert "$IMG" \
  -gravity South -crop "${WIDTH}x${COLOR_HEIGHT}+0+0" +repage \
  "bottom.jpg"

convert top.jpg bottom.jpg -append "$OUT"

if (( LEFT % 10 == 1 && LEFT % 100 != 11 )); then
  WORD="день"
elif (( LEFT % 10 >= 2 && LEFT % 10 <= 4 && (LEFT % 100 < 12 || LEFT % 100 > 14) )); then
  WORD="дня"
else
  WORD="дней"
fi

TITLE="12.12.26 Концерт — $LEFT $WORD"

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/setChatTitle \
  -d chat_id=$CHAT_ID \
  -d title="$TITLE"

# # Upload
# curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/setChatPhoto" \
#  -F chat_id="$CHAT_ID" \
#  -F photo=@"$OUT"

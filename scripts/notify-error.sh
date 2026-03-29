#!/bin/sh
# Notification script called by tiredofit/db-backup on backup FAILURE.
# Args: $1=timestamp $2=logfile $3=error_code $4=subject $5=body

TIMESTAMP="$1"
LOGFILE="$2"
ERROR_CODE="$3"
SUBJECT="$4"
BODY="$5"

[ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ] && exit 0

TEXT="BACKUP FAILED

${SUBJECT}
Error code: ${ERROR_CODE}
Time: ${TIMESTAMP}

${BODY}"

curl -sf -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${TEXT}" || true

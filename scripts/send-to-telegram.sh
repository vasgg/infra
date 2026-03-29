#!/bin/sh
# Post-backup hook: sends backup file to Telegram via Bot API.
# Mounted to /assets/scripts/post/ — auto-executed by tiredofit/db-backup after each job.
# Always exits 0 so a Telegram failure never breaks the backup process.

BACKUP_FILE="$1"

[ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ] && exit 0

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "[telegram] file not found: '$BACKUP_FILE'" >&2
    exit 0
fi

FILENAME=$(basename "$BACKUP_FILE")
FILE_SIZE=$(wc -c < "$BACKUP_FILE")
SIZE_H=$((FILE_SIZE / 1024))
[ "$SIZE_H" -ge 1024 ] && SIZE_H="$((SIZE_H / 1024))MB" || SIZE_H="${SIZE_H}KB"

if [ "$FILE_SIZE" -gt 52428800 ]; then
    curl -sf -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="Backup OK: ${FILENAME} (${SIZE_H}) — exceeds 50MB Telegram limit, file saved locally only" || true
    exit 0
fi

curl -sf -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" \
    -F document=@"${BACKUP_FILE}" \
    -F caption="OK: ${FILENAME} (${SIZE_H})" || true

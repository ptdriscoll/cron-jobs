#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

export LC_ALL=C.UTF-8

# default log values
MAX_LOG_LINES=1000
MAX_APP_LOGS=30

# get absolute path to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(realpath "$SCRIPT_DIR")"

CONFIG_FILE="$(realpath "$1")"
if [ -z "$CONFIG_FILE" ]; then
  echo "No config file provided. Usage: $0 path/to/job_config.sh"
  exit 1
fi

# load config
source "$CONFIG_FILE"
export SIMULATE_FAILURE

# set default LOG_DIR if not provided in config
LOG_DIR="${LOG_DIR:-$REPO_ROOT/logs/$APP_NAME}"

# ensure log directory exists
mkdir -p "$LOG_DIR"

# define log file paths
: "${LOG_EXTENSION=.log}"
CHRON_LOG="$LOG_DIR/chron$LOG_EXTENSION"
LOG_TIMESTAMP=$(date '+%F_%H-%M-%S')
APP_LOG="$LOG_DIR/${APP_NAME}_$LOG_TIMESTAMP$LOG_EXTENSION"

echo "[$(date '+%F %T')] STARTING job for $APP_NAME" >> "$CHRON_LOG"

"$EXECUTABLE_PATH" "$SCRIPT_PATH" >> "$APP_LOG" 2>&1
status=$?

send_email() {
  local subject="$1"
  local body="$2"
  printf "%b" "$body" | mail -s "$subject" "$TO_EMAIL"
}

compose_body() {
  local status_msg="$1"
  local base_body="Cron job for $APP_NAME ${status_msg}.\n\nTime: $(date)"

  if [ "$EMAIL_OUTPUT" = "true" ]; then
    if [ -s "$APP_LOG" ]; then
      base_body="${base_body}\n\nOutput:\n\n$(cat "$APP_LOG")"
    else
      base_body="${base_body}\n\n(No output was produced by script.)"
    fi
  else
    base_body="${base_body}\n\n(Output not included — EMAIL_OUTPUT=false)"
  fi

  base_body="${base_body}\n\nSee logs:\n$CHRON_LOG\n$APP_LOG"
  printf "%b" "$base_body"
}

# on failure
if [ "$status" -ne 0 ]; then
  echo "[$(date '+%F %T')] ERROR: $APP_NAME failed with exit status $status" >> "$CHRON_LOG"
  if [ "${EMAIL_ON_FAILURE:-false}" = "true" ] && [ -n "${TO_EMAIL:-}" ]; then
    SUBJECT="[Cron Failure] $APP_NAME on $(hostname) - $LOG_TIMESTAMP"
    BODY=$(compose_body "failed with exit status $status")
    send_email "$SUBJECT" "$BODY"
  fi
else # on success
  echo "[$(date '+%F %T')] SUCCESS: $APP_NAME completed successfully" >> "$CHRON_LOG"
  if [ "${EMAIL_ON_SUCCESS:-false}" = "true" ] && [ -n "${TO_EMAIL:-}" ]; then
    SUBJECT="[Cron Success] $APP_NAME on $(hostname) - $LOG_TIMESTAMP"
    BODY=$(compose_body "completed successfully")
    send_email "$SUBJECT" "$BODY"
  fi
fi

# clean up old app logs (keep only most recent MAX_APP_LOGS)
mapfile -t old_logs < <(
  find "$LOG_DIR" -maxdepth 1 -name "${APP_NAME}_*${LOG_EXTENSION}" -type f \
    -exec stat -c '%Y %n' {} + 2>/dev/null | sort -n | head -n -"$MAX_APP_LOGS" | cut -d' ' -f2-
)

if [ "${#old_logs[@]}" -gt 0 ]; then
  echo "[$(date '+%F %T')] Deleting old app logs:" >> "$CHRON_LOG"
  printf "  %s\n" "${old_logs[@]}" >> "$CHRON_LOG"
  rm -f -- "${old_logs[@]}"
fi

echo "[$(date '+%F %T')] FINISHED job for $APP_NAME" >> "$CHRON_LOG"

# trim CHRON_LOG to last MAX_LOG_LINES
tail -n "$MAX_LOG_LINES" "$CHRON_LOG" > "$CHRON_LOG.tmp" && mv "$CHRON_LOG.tmp" "$CHRON_LOG" || true

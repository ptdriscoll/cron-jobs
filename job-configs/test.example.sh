#!/bin/bash

# Example cron job config for scripts/test.php
# Run using: ./run-cron.sh job-configs/test.example.sh

APP_NAME="test"

# path to script that cron job runs
SCRIPT_PATH="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../scripts/test.php")"

# path to interpreter 
EXECUTABLE_PATH="${EXECUTABLE_PATH:-php}"

# email settings
EMAIL_ON_FAILURE=false
EMAIL_ON_SUCCESS=false
EMAIL_OUTPUT=false
TO_EMAIL=""

# optional: override log file extension, (default: .log)
# must include leading dot (e.g., ".txt"), except when setting no extension (e.g., "")
#LOG_EXTENSION=".log"

# optional: override log directory location (default: cron-jobs/logs/$APP_NAME)
#LOG_DIR="$(dirname "${BASH_SOURCE[0]}")/../logs/$APP_NAME"

# optional: limit cron status log lines, and app log output files (defaults: 1000, 30)
MAX_LOG_LINES=100
MAX_APP_LOGS=5

# toggle to simulate failure
SIMULATE_FAILURE=false

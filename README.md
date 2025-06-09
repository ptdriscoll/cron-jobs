# Cron Job Runner

This project provides a flexible and logged cron job runner that supports:

- Configurable script execution (e.g. PHP, Python)
- Logging of execution status and output
- Optional email notifications on success/failure
- Automatic cleanup of old logs
- Per-job customization via config files

---

## 📁 Project Structure

```
cron-jobs/
├── job-configs/
│   └── test.example.sh    # example config file
├── logs/                  # default location for log files
├── scripts/
│   └── test.php           # actual code being run from config file
└── run-cron.sh            # runs job config
```

---

## 🚀 Run Example

Option 1: From repo root:

```
git clone https://github.com/your-org/cron-jobs.git
./cron-jobs/run-cron.sh cron-jobs/job-configs/test.example.sh
```

Option 2: Go into cron-jobs directory:

```
git clone https://github.com/your-org/cron-jobs.git
cd cron-jobs
./run-cron.sh job-configs/test.example.sh
```

## 🛠 Configuration

Each job gets its own config file, under `job-configs/` with options like:

```
APP_NAME="test"
SCRIPT_PATH="/absolute/path/to/script.php"
EXECUTABLE_PATH="/usr/bin/php"

# email settings
EMAIL_ON_SUCCESS=false
EMAIL_ON_FAILURE=false
EMAIL_OUTPUT=false
TO_EMAIL=""

# logging settings (optional)
LOG_EXTENSION=".log"          # default: .log — set to "" for no extension
LOG_DIR="/custom/log/dir"     # default: cron-jobs/logs/$APP_NAME
MAX_LOG_LINES=1000            # default: 1000 (for status log)
MAX_APP_LOGS=30               # default: 30 (for app output logs)

# simulate failure (for testing)
SIMULATE_FAILURE=false
```

You can copy and edit `test.example.sh` to create your own job:

```
cd cron-jobs
cp job-configs/test.example.sh job-configs/my-job.sh
chmod +x job-configs/my-job.sh
```

## 📬 Email Setup

In job config file:

- Set `EMAIL_ON_SUCCESS` to true or false (default: `false`)
- Set `EMAIL_ON_FAILURE` to true or false (default: `false`)
- Set `TO_EMAIL` to your address (default: `none`)
- Set `EMAIL_OUTPUT=true` to include job output in message (default: `false`)

## 🧹 Log Files and Cleanup

In job config file:

- Set `MAX_LOG_LINES` to number of cron status lines to keep (default: `1000`)
- Set `MAX_APP_LOGS` number of app output files to keep (default: `30`)
- Override `LOG_EXTENSION`, e.g. `.txt`, or `""` for no extension (default: `.log`)
- Override `LOG_DIR` log directory location (default `cron-jobs/logs/$APP_NAME`)

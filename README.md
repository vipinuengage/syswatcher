# Syswatcher

Syswatcher is a **lightweight system monitoring utility for Ubuntu** that periodically checks **CPU, RAM, and Disk usage** and sends alerts to **Google Chat** when configured thresholds are exceeded.

It is designed to be:

* Minimal and dependency-free
* Easy to install and manage
* Fully systemd-based (timer-driven)

---

## Features

* Monitors CPU, RAM, and Disk usage
* Configurable thresholds
* Google Chat webhook alerts
* Cooldown mechanism to avoid alert spam
* Runs automatically every minute using systemd timer
* Simple CLI management via `syswatcherctl`

---

## Requirements

* Ubuntu (systemd-based)
* bash
* curl

---

## Installation

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/vipinuengage/syswatcher/main/install.sh | sudo bash
```

During installation, you will be prompted for:

* CPU threshold (%)
* RAM threshold (%)
* Disk threshold (%)
* Disk mount path (e.g. `/`)
* Google Chat webhook URL
* Alert cooldown (seconds)

<!-- ---

### Update (via install.sh)

You can update syswatcher to the latest version using the same installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/vipinuengage/syswatcher/main/install.sh | sudo bash -s update
```

This will:

* Download the latest `syswatcher` and `syswatcherctl`
* Preserve existing configuration
* Restart the systemd timer

---

### Remove / Uninstall (via install.sh)

To completely remove syswatcher from the system:

```bash
curl -fsSL https://raw.githubusercontent.com/vipinuengage/syswatcher/main/install.sh | sudo bash -s remove
```

This removes:

* Binaries
* Configuration files
* State files
* systemd service and timer -->

---

## How It Works

* A **systemd timer** runs `syswatcher` every minute
* Resource usage is calculated
* If any metric crosses its threshold:

  * A Google Chat alert is sent
  * A cooldown timestamp is stored to prevent repeated alerts

---

## Configuration

Configuration file location:

```text
/etc/syswatcher/config.conf
```

Example configuration:

```bash
CPU_THRESHOLD=80
RAM_THRESHOLD=75
DISK_THRESHOLD=85
DISK_PATH="/"
WEBHOOK_URL="https://chat.googleapis.com/..."
HOSTNAME_OVERRIDE=""
COOLDOWN_SECONDS=300
```

### Configuration Options

| Variable          | Description                            | Required |
| ----------------- | -------------------------------------- | -------- |
| CPU_THRESHOLD     | CPU usage percentage to trigger alert  | Yes      |
| RAM_THRESHOLD     | RAM usage percentage to trigger alert  | Yes      |
| DISK_THRESHOLD    | Disk usage percentage to trigger alert | Yes      |
| DISK_PATH         | Disk mount path to monitor             | Yes      |
| WEBHOOK_URL       | Google Chat webhook URL                | Yes      |
| HOSTNAME_OVERRIDE | Optional custom hostname in alerts     | No       |
| COOLDOWN_SECONDS  | Minimum seconds between alerts         | Yes      |

---

## CLI Commands (`syswatcherctl`)

`syswatcherctl` is the preferred management interface after installation.

### Show status

```bash
sudo syswatcherctl status
```

Shows whether the systemd timer is active.

---

### Show configuration

```bash
sudo syswatcherctl config show
```

Prints the current configuration values.

---

### Edit configuration

```bash
sudo syswatcherctl config edit
```

Opens the configuration file in the default editor.

---

### Reset configuration

```bash
sudo syswatcherctl config reset
```

Deletes the existing config and recreates it with default values.

---

### Update syswatcher

```bash
sudo syswatcherctl update
```

Downloads and installs the latest version while preserving configuration.

---

### Remove syswatcher

```bash
sudo syswatcherctl remove
```

Completely removes:

* Binaries
* Config files
* State files
* systemd service and timer

---

## systemd Units

Installed units:

* `syswatcher.service` – One-shot execution
* `syswatcher.timer` – Runs every minute

Check timer status:

```bash
systemctl list-timers | grep syswatcher
```

---

## Manual Execution (Debugging)

You can run syswatcher manually:

```bash
sudo /usr/local/bin/syswatcher
```

For detailed tracing:

```bash
sudo bash -x /usr/local/bin/syswatcher
```

---

## Alert Cooldown

Syswatcher stores the last alert timestamp at:

```text
/var/lib/syswatcher/last_alert
```

To force alerts during testing:

```bash
sudo rm -f /var/lib/syswatcher/last_alert
```

---

## Uninstall

```bash
sudo syswatcherctl remove
```

---

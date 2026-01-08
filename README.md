# Syswatcher

Syswatcher is a **lightweight Ubuntu system monitor** that checks **CPU, RAM, and disk usage** and sends alerts to a **Google Chat webhook** when thresholds are exceeded.

It has **no runtime dependencies**, runs via `systemd`, and is easy to install, update, and remove.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/vipinuengage/syswatcher/main/install.sh | sudo bash
```

You will be prompted for thresholds and webhook URL during installation.

---

## Usage

Check status:

```bash
sudo syswatcherctl status
```

Edit config:

```bash
sudo syswatcherctl config edit
```

View config:

```bash
sudo syswatcherctl config show
```

Reset config:

```bash
sudo syswatcherctl config reset
```

---

## Update

```bash
sudo syswatcherctl update
```

---

## Remove

```bash
sudo syswatcherctl remove
```

---

## Config File

```text
/etc/syswatcher/config.conf
```

Example:

```bash
CPU_THRESHOLD=80
RAM_THRESHOLD=75
DISK_THRESHOLD=85
DISK_PATH="/"
WEBHOOK_URL="https://chat.googleapis.com/..."
COOLDOWN_SECONDS=300
```

---

## Requirements

* Ubuntu (systemd)
* bash
* curl

---

## License

MIT
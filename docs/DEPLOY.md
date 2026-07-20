<!-- title: Nok Hoo — Deploy Guide -->

# Deploy Guide

**You need:** 2 Linux VMs with Docker + Compose v2, and a Gmail App Password for alerts ([create one here](https://myaccount.google.com/apppasswords) — requires 2FA).

## 1. Clone and configure

```bash
git clone https://github.com/<your-org>/nokhoo.git
cd nokhoo

cp vm_container/.env.example vm_container/.env   # just set TZ
cp vm_monitor/.env.example  vm_monitor/.env      # TZ + credentials
```

Fill in `vm_monitor/.env`:

```env
TZ=Asia/Bangkok

GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=<pick_a_strong_one>

POSTGRES_HOST=192.168.1.100
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<your_db_password>

ALERT_EMAIL_FROM=alert@yourdomain.com
ALERT_EMAIL_PASSWORD=<gmail_app_password>
ALERT_EMAIL_TO=you@yourdomain.com
```

> Using different IPs? Update `extra_hosts` in both compose files — that's the only place the VM IPs live.

## 2. Deploy

```bash
# Workload VM
scp -r vm_container/ user@192.168.1.200:~/monitoring
ssh user@192.168.1.200 "cd ~/monitoring && docker compose up -d"

# Monitoring VM
scp -r vm_monitor/ user@192.168.1.201:~/monitoring
ssh user@192.168.1.201 "cd ~/monitoring && docker compose up -d"
```

## 3. Check it works

```bash
# Every target should say "up"
curl -s http://192.168.1.201:9090/api/v1/targets | grep -o '"health":"[a-z]*"'
```

Then open **Grafana → `http://192.168.1.201:3000`** and enjoy your new dashboards.

## Reloading config

Changed `prometheus.yml`? No restart needed:

```bash
curl -X POST http://192.168.1.201:9090/-/reload
```

## Adding your own services

Monitoring another VM takes three steps: deploy the `vm_container/` compose there, add a scrape job in `prometheus.yml` with a new `vm:` label (plus an `extra_hosts` entry), and hot-reload. Your new host shows up in the same dashboards automatically.

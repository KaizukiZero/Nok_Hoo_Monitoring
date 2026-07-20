# Nok Hoo 🦉

> **The owl that never sleeps.** Everything you need to monitor Docker workloads across VMs — metrics, logs, uptime checks, and email alerts. Clone, configure one `.env` file, and the owl is watching your infrastructure in minutes.

*"Nok Hoo" (นกฮูก) is Thai for **owl** — the night watcher that sees everything in the dark. That's exactly what this stack does: it stays awake so you don't have to.*

![Docker](https://img.shields.io/badge/Docker-Compose%20v2-2496ED?logo=docker&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-v3.12-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-13.1-F46800?logo=grafana&logoColor=white)
![Loki](https://img.shields.io/badge/Loki-3.6-F5A800)
![License](https://img.shields.io/badge/License-MIT-green)

⭐ **If this stack saves you a weekend of setup, a star means a lot!**

---

## Why Nok Hoo exists

Setting up monitoring *properly* is harder than it looks. Most tutorials show you Prometheus and Grafana on a single machine with default settings — then you hit the real world: workloads on one VM, monitoring on another, logs scattered everywhere, no alerts until users complain, and passwords hardcoded in config files.

This repo is the setup I wish I had on day one:

- **Two-VM design** that mirrors real infrastructure — agents on the workload host, the monitoring brain on its own VM
- **Alerts that actually reach you** — 11 battle-tested rules routed to your email, before things catch fire
- **Logs and metrics in one place** — jump from a CPU spike to the exact log line in Grafana
- **Secrets done right** — everything sensitive lives in `.env` (git-ignored), configs are mounted read-only
- **No `latest` tags, no surprises** — every image version is pinned

## What's in the box

```text
vm_container (192.168.1.200)              vm_monitor (192.168.1.201)
┌──────────────────────────┐              ┌───────────────────────────────┐
│ app-web-1..7  :8081-8087 │◀──HTTP probe─│ Blackbox Exporter   :9115     │
│                          │              │        │                      │
│ cAdvisor        :8080 ───┼──metrics────▶│ Prometheus          :9090     │
│ node-exporter   :9100 ───┼──metrics────▶│   ├── Alertmanager  :9093 ──▶ 📧
│ promtail        :9080 ───┼──logs───────▶│ Loki                :3100     │
└──────────────────────────┘              │   └── Grafana       :3000     │
                                          │ postgres-exporter   :9187     │
PostgreSQL (192.168.1.100:5432) ◀─────────│                               │
                                          └───────────────────────────────┘
```

| You want to know… | Covered by |
|---|---|
| Is my container eating CPU/RAM? | cAdvisor → dashboard 14282 |
| Is the host disk filling up? | node-exporter + `LowDiskSpace` alert |
| Is my website actually up? | Blackbox HTTP probes → dashboard 7587 |
| Why did it crash at 3 AM? | Promtail → Loki → Grafana Explore |
| Is PostgreSQL healthy? | postgres-exporter → dashboard 9628 |
| Will anyone tell me? | Alertmanager → your inbox 📧 |

Grafana comes with **datasources and 3 dashboards auto-provisioned** — open it and the graphs are already there. No clicking through setup wizards.

## Quick start

**You need:** 2 Linux VMs with Docker + Compose v2, and a Gmail App Password for alerts ([create one here](https://myaccount.google.com/apppasswords) — requires 2FA).

Full clone/configure/deploy/verify steps: **[Deploy Guide](docs/DEPLOY.md)**.

## The alerts you'll get

| When… | You'll know within |
|---|---|
| CPU / RAM / disk crosses 70% | 3 minutes ⚠️ |
| CPU / RAM / disk crosses 90% | 2 minutes 🔴 |
| Free disk drops below 10 GB | right away 🔴 |
| A container disappears | 1 minute 🔴 |
| An HTTP endpoint stops responding | 1 minute 🔴 |
| PostgreSQL goes down | 1 minute 🔴 |
| DB connections exceed 80% of max | as it happens ⚠️ |

Critical alerts re-notify every hour until fixed; warnings every 4 hours — enough to act, not enough to make you mute the channel.

## Security — what's covered, what's honest

Done for you: secrets only in git-ignored `.env`, read-only config mounts, pinned image versions, Gmail App Password (never your real password), Grafana sign-up disabled, per-service CPU/RAM limits.

Be aware (trusted-LAN assumptions — see [Roadmap](#roadmap)):

- Exporter ports and web UIs are plain HTTP without auth → **restrict them with your firewall**: workload ports (8080, 9100, 8081–8087) only from the monitor IP; Loki 3100 only from the workload IP; UIs (3000, 9090, 9093) only from your admin subnet
- postgres-exporter connects with `sslmode=disable` → enable TLS on your DB if it leaves the trusted network

## When something breaks

See **[Troubleshooting](docs/TROUBLESHOOTING.md)**.

## Adding your own services

Monitoring another VM takes three steps: deploy the `vm_container/` compose there, add a scrape job in `prometheus.yml` with a new `vm:` label (plus an `extra_hosts` entry), and hot-reload — see **[Deploy Guide](docs/DEPLOY.md#adding-your-own-services)** for the reload command.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## Contributing

Contributions of any size are welcome — fixing a typo, improving a dashboard, adding an alert rule, or translating docs.

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-idea`
3. Commit (please never commit `.env` 🙏)
4. Open a Pull Request — I read every one

Not sure where to start? Check the issues labeled `good first issue`, or just open a discussion.

## Support the owl 🦉

If Nok Hoo helped you monitor your infrastructure without the usual week of pain:

- ⭐ **Star the repo** — it genuinely helps others find it
- 🐛 **Report bugs** — even small ones make it better for everyone
- 💬 **Share your setup** — different environments and use cases are always interesting

## License

MIT — use it, fork it, ship it at work. No strings attached.

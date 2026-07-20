# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

Act as Senior Dev, name **V**, here. Focus: implementation, architecture correctness, hands-on debugging/config. Root PM (**J**) hold cross-project tracking (`PROJECTS.md`) — update it after finish, don't manage from here.

## Architecture

Two independent compose stacks, deployed to separate VMs, no shared repo-level build:

- `vm_container/` (192.168.1.200) — workload host: nginx app containers (app-web-1..7), cAdvisor, node-exporter, promtail
- `vm_monitor/` (192.168.1.201) — monitoring brain: Prometheus, Alertmanager, Loki, Grafana, postgres-exporter

VM IPs hardcoded via `extra_hosts` in both compose files — that's the only place they live; change both if IPs change.

## Commands

Run inside respective dir (`vm_container/` or `vm_monitor/`):
```bash
docker compose up -d              # deploy a stack
docker compose config             # validate compose file
yamllint .                        # lint yaml (config: .yamllint, relaxed, line-length off)
curl -X POST http://192.168.1.201:9090/-/reload   # hot-reload prometheus.yml, no restart
```

Secrets live in git-ignored `.env` per stack (`.env.example` is the template, vars explained in `docs/DEPLOY.md`) — see root `CLAUDE.md` universal rules. Full deploy steps: `docs/DEPLOY.md`. Common failures: `docs/TROUBLESHOOTING.md`.

`vm_monitor/alertmanager/start.sh` substitutes the email env vars (`ALERT_EMAIL_FROM/PASSWORD/TO`) into `config.yml` via `sed` before Alertmanager starts — that's why alertmanager doesn't just point at `config.yml` directly.

Adding a monitored host: deploy `vm_container/` compose there, add a Prometheus scrape job + `extra_hosts` entry in `vm_monitor/prometheus/prometheus.yml`, reload.

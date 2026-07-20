<!-- title: Nok Hoo — Troubleshooting -->

# Troubleshooting

| Symptom | Try this first |
|---|---|
| Target shows `down` | `docker exec prometheus-mst wget -qO- http://vm_container:8080/metrics` — if the name doesn't resolve, check `extra_hosts` matches your real IPs |
| No logs in Grafana | `curl http://192.168.1.200:9080/ready` then `curl http://192.168.1.201:3100/ready` — one of them will tell you who's sulking |
| No alert emails | `docker logs alertmanager-mst` — 9 times out of 10 it's a regular password where the App Password should be |
| PostgreSQL panel empty | `nc -zv 192.168.1.100 5432` from the monitor VM, then check `.env` credentials |
| Container keeps restarting | `docker logs <container>` and check for OOM: `docker inspect <container> | grep OOM` |

See [Deploy Guide](DEPLOY.md) for reload/redeploy commands.

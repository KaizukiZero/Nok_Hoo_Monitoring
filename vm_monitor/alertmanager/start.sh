#!/bin/sh
# Substitute env vars into alertmanager config before starting
sed \
  -e "s|\${ALERT_EMAIL_FROM}|${ALERT_EMAIL_FROM}|g" \
  -e "s|\${ALERT_EMAIL_PASSWORD}|${ALERT_EMAIL_PASSWORD}|g" \
  -e "s|\${ALERT_EMAIL_TO}|${ALERT_EMAIL_TO}|g" \
  /etc/alertmanager/config.yml > /tmp/alertmanager.yml

exec /bin/alertmanager \
  --config.file=/tmp/alertmanager.yml \
  --storage.path=/alertmanager

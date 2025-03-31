#!/bin/sh

wget -O /usr/local/bin/talosctl https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-amd64
chmod +x /usr/local/bin/talosctl

echo "0 * * * * /bin/sh /app/cron.sh" > /var/spool/cron/crontabs/root

crond -f

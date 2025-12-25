#!/bin/sh

find /data -type f -mtime +6 -exec rm -f {} \;
talosctl -n $NODE etcd snapshot /data/etcd-$(date +%s).snapshot

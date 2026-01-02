#!/bin/sh

find /data -type f -mtime +5 -exec rm -f {} \;
talosctl -n $NODE etcd snapshot /data/etcd-$(date +%s).snapshot

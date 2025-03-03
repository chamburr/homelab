#!/bin/ash

main() {
  mosquitto_passwd -c -b /mosquitto/password.txt "$MQ_USERNAME" "$MQ_PASSWORD"
  /docker-entrypoint.sh
  /usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf
}

main "$@"

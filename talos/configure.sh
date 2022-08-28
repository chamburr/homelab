#!/bin/sh

if [ "${PWD##*/}" != '.talos' ]; then
  echo 'Not in correct directory, exiting...'
fi

curl -O https://github.com/chamburr/homelab/blob/master/talos/machines.yaml
curl -O https://github.com/chamburr/homelab/blob/master/talos/patch.yaml

talosctl gen config cluster https://192.168.122.10:6443 \
  --config-patch @patch.yaml --with-docs=false --with-examples=false

nodes=$(yq -o=j -I=0 '.nodes[]' machines.yaml)
endpoints=$(yq '.nodes[] | .endpoint' machines.yaml | xargs)

for node in $nodes; do
  name=$(echo $node | jq -r '.name')
  endpoint=$(echo $node | jq -r '.endpoint')

  filename="$name.yaml"
  ip=$(virsh net-dhcp-leases default | grep $name | grep -oE '192.168.122.{1,4}')

  cp controlplane.yaml $filename
  sed -i -e "s/\$ENDPOINT/$endpoint/g" -e "s/\$HOSTNAME/$name/g" $filename

  talosctl apply-config --insecure --nodes $ip --file $filename

  rm $filename
done

talosctl config endpoint $endpoints --talosconfig ./talosconfig
talosctl config node $endpoints --talosconfig ./talosconfig
talosctl config merge ./talosconfig

until talosctl version > /dev/null 2>&1; do
  sleep 5
done

talosctl bootstrap --nodes $(echo $endpoints | cut -f 1 -d ' ')
talosctl kubeconfig

rm controlplane.yaml worker.yaml talosconfig
rm machines.yaml patch.yaml

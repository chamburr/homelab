#!/bin/sh

prepare() {
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  export USERNAME="${PWD##*/}"
  export TALOSCONFIG="/home/$USERNAME/.talos/config"
  export KUBECONFIG="/home/$USERNAME/.kube/config"
}

run() {
  echo 'Running...'

  mkdir -p .talos .kube
  cd .talos

  curl -sO https://raw.githubusercontent.com/chamburr/homelab/main/talos/config.yaml
  curl -sO https://raw.githubusercontent.com/chamburr/homelab/main/talos/patch.yaml

  config=$(cat config.yaml | python3 -c \
    'import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin.read())))')

  clustername=$(echo $config | jq -r '.cluster.name')
  clusterendpoint=$(echo $config | jq -r '.cluster.endpoint')
  nodes=$(echo $config | jq -cr '.nodes.[]')

  talosctl gen secrets -o secrets.yaml
  talosctl gen config $clustername https://$clusterendpoint:6443 --with-secrets secrets.yaml \
    --with-docs=false --with-examples=false --config-patch @patch.yaml --config-patch \
    '[{"op":"replace","path":"/cluster/apiServer/admissionControl","value":[]}]'

  mv talosconfig config
  talosctl config endpoint $clusterendpoint

  for node in $nodes; do
    name=$(echo $node | jq -r '.name')
    endpoint=$(echo $node | jq -r '.endpoint')
    filename="$name.yaml"

    cp controlplane.yaml $filename
    sed -i -e "s/\$HOST/$name/g" -e "s/\$DOCKER_USERNAME/$DOCKER_USERNAME/g" \
      -e "s/\$DOCKER_PASSWORD/$DOCKER_PASSWORD/g" $filename
    talosctl apply-config --insecure -n $endpoint -f $filename
    rm $filename

    until talosctl version -e $endpoint -n $endpoint > /dev/null 2>&1; do
      sleep 1
    done
  done

  rm controlplane.yaml worker.yaml
  rm config.yaml patch.yaml

  endpoint=$(echo $config | jq -r '.nodes[0].endpoint')
  talosctl bootstrap -e $endpoint -n $endpoint
  talosctl kubeconfig -e $endpoint -n $endpoint ../.kube/config

  until talosctl health -n $clusterendpoint --wait-timeout 5s 2>&1 \
    | grep -q 'waiting for all k8s nodes to report ready'; do
    sleep 1
  done

  kustomize build --enable-helm \
    "https://github.com/chamburr/homelab.git/kubernetes/kube-system/cilium?ref=main" \
    | kubectl apply -f -
  kustomize build --enable-helm \
    "https://github.com/chamburr/homelab.git/kubernetes/kube-system/coredns?ref=main" \
    | kubectl apply -f -

  until talosctl health -n $clusterendpoint --wait-timeout 5s > /dev/null 2>&1; do
    sleep 1
  done

  kubectl create namespace argocd
  kustomize build --enable-helm \
    "https://github.com/chamburr/homelab.git/kubernetes/argocd/argocd?ref=main" \
    | kubectl apply -f -
  kustomize build --enable-helm \
    "https://github.com/chamburr/homelab.git/kubernetes/argocd/argocd-apps?ref=main" \
    | kubectl apply -f -
}

prepare
run

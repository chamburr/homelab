#!/bin/sh

helm template cilium cilium/cilium --namespace kube-system -f talos/cilium/values.yaml > talos/cilium/install.yaml

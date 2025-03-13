# Homelab

My personal infrastructure and Kubernetes cluster written as code.

This project utilises Infrastructure as Code and GitOps to automate the provisioning, operating and
updating of self-hosted services in my homelab. Furthermore, this repository can also serve as a
good framework for you to build your own homelab.

Feel free to open a [GitHub issue](https://github.com/chamburr/homelab/issues) if you have any
questions!

## Installation

First, configure a gateway running OPNsense, get a controller running Ubuntu, and install Talos
Linux on several servers for Kubernetes nodes. Then, install the prerequisites in Brewfile
and update Ansible and environmental variables. Finally, run `./scripts/bootstrap.sh` to install
everything on the controller and Kubernetes nodes!

## Core components

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/1507452?s=200&v=4"></td>
    <td><a href="https://ansible.com">Ansible</a></td>
    <td>Bare metal provisioning and configuration</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/30269780?s=200&v=4"></td>
    <td><a href="https://argoproj.github.io/cd">Argo CD</a></td>
    <td>GitOps operator for managing Kubernetes cluster</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/21054566?s=200&v=4"></td>
    <td><a href="https://cilium.io">Cilium</a></td>
    <td>Cloud native internal networking for Kubernetes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/13629408?s=200&v=4"></td>
    <td><a href="https://kubernetes.io">Kubernetes</a></td>
    <td>Orchestration system for managing containers</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/9979117?s=200&v=4"></td>
    <td><a href="https://opnsense.org">OPNsense</a></td>
    <td>Operating system for external gateway</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/3380462?s=200&v=4"></td>
    <td><a href="https://prometheus.io">Prometheus</a></td>
    <td>Monitoring system for metrics and alerting</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/2678585?s=200&v=4"></td>
    <td><a href="https://www.proxmox.com">Proxmox</a></td>
    <td>Virtualization platform for virtual machines</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/rookio/rookio-icon.svg"></td>
    <td><a href="https://rook.io">Rook Ceph</a></td>
    <td>Cloud native storage for Kubernetes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/13804887?s=200&v=4"></td>
    <td><a href="https://talos.dev">Talos Linux</a></td>
    <td>Linux distribution for Kubernetes nodes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://icon.icepanel.io/Technology/svg/Traefik-Proxy.svg"></td>
    <td><a href="https://traefik.io">Traefik</a></td>
    <td>Cloud native ingress controller for Kubernetes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/4604537?s=200&v=4"></td>
    <td><a href="https://ubuntu.com">Ubuntu</a></td>
    <td>Linux distribution for controller</td>
  </tr>
  <tr>
    <td><img width="32" src="https://icon.icepanel.io/Technology/svg/HashiCorp-Vault.svg"></td>
    <td><a href="https://vaultproject.io">Vault</a></td>
    <td>Secrets and encryption management system</td>
  </tr>
  <tr>
    <td><img width="32" src="https://avatars.githubusercontent.com/u/84780935?s=200&v=4"></td>
    <td><a href="https://woodpecker-ci.org">Woodpecker</a></td>
    <td>Continuous integration and delivery platform</td>
  </tr>
</table>

## Hardware

My infrastructure currently consists of multiple nodes with the following specifications.

- Gateway, Controller, Talos 1: Miniroute R1, Intel N100, 16GB RAM, 512GB SSD
- Talos 2: ThinkCenter M920x, Intel i5-8600T, 32GB RAM, 256GB + 1TB SSD
- Talos 3: ThinkCenter M920x, Intel i5-8600T, 32GB RAM, 256GB + 1TB SSD

## License

This project is licensed under the [MIT License](LICENSE).

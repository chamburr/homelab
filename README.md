# Homelab

My personal infrastructure and Kubernetes cluster written as code.

This project utilises Infrastructure as Code and GitOps to automate the provisioning, operating and
updating of self-hosted services in my homelab. These services are essential for my everyday life.
Furthermore, this repository can also serve as a good framework for you to build your own homelab.

Feel free to open a [GitHub issue](https://github.com/chamburr/homelab/issues) if you have any
questions!

## Installation

First, configure a bare metal Rocky Linux machine with reference to
[kickstart.ks](https://github.com/chamburr/homelab/blob/main/scripts/anaconda/kickstart.ks). Then,
install prerequisites in Brewfile and update Ansible and environmental variables. Finally, run
`./scripts/bootstrap.sh` to install everything on the server!

## Core components

<table>
  <tr>
    <th>Logo</th>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/ansible/ansible-icon.svg"></td>
    <td><a href="https://ansible.com">Ansible</a></td>
    <td>Bare metal provisioning and configuration</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/fluxcdio/fluxcdio-icon.svg"></td>
    <td><a href="https://fluxcd.io">Flux</a></td>
    <td>GitOps operator for managing Kubernetes cluster</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/kubernetes/kubernetes-icon.svg"></td>
    <td><a href="https://kubernetes.io">Kubernetes</a></td>
    <td>Orchestration system for managing containers</td>
  </tr>
  <tr>
    <td><img width="32" src="https://cdn.worldvectorlogo.com/logos/rocky-linux.svg"></td>
    <td><a href="https://rockylinux.org">Rocky Linux</a></td>
    <td>Main operating system for infrastructure</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/rookio/rookio-icon.svg"></td>
    <td><a href="https://rook.io">Rook Ceph</a></td>
    <td>Cloud native block storage for Kubernetes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://talos.dev/images/logo.svg"></td>
    <td><a href="https://talos.dev">Talos Linux</a></td>
    <td>Base operating system for Kubernetes nodes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/traefikio/traefikio-icon.svg"></td>
    <td><a href="https://traefik.io">Traefik</a></td>
    <td>Cloud native ingress controller for Kubernetes</td>
  </tr>
  <tr>
    <td><img width="32" src="https://vectorlogo.zone/logos/vaultproject/vaultproject-icon.svg"></td>
    <td><a href="https://vaultproject.io">Vault</a></td>
    <td>Secrets and encryption management system</td>
  </tr>
</table>

## Hardware

My cluster currently consists of a single node with the following specifications.

- CPU: Intel Xeon E5-2683v4
- RAM: Micron 16GB DDR4 ECC x2
- SSD: Samsung 980 NVMe 500GB
- HDD: Seagate IronWolf 4TB x2

## Acknowledgements

Special thanks to the [Kubernetes @Home](https://github.com/k8s-at-home/) community for inspiration
and support!

## License

This project is licensed under the [MIT License](LICENSE).

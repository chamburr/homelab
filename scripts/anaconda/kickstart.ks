#version=RHEL9

# Use graphical install
graphical

repo --name="minimal" --baseurl=file:///run/install/sources/mount-0000-cdrom/minimal

%addon com_redhat_kdump --disable

%end

# Keyboard layouts
keyboard --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp6s0 --ipv6=auto --activate

# Use CDROM installation media
cdrom

%packages
@^minimal-environment

%end

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.4.0
ignoredisk --only-use=nvme0n1

# Partition clearing information
clearpart --none --initlabel

# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=nvme0n1 --size=600 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="ext4" --ondisk=nvme0n1 --size=1024
part / --fstype="ext4" --ondisk=nvme0n1 --size=475315

# System timezone
timezone Asia/Singapore --utc

# Root password
rootpw --iscrypted $6$PHLr.S52ucJHaAjP$noihHEemRm0hu6FUt9WQVOsuV9XRgR26QydkCZMNC7YECJaR2n7SPpkaCNTm7F2xruNguar4fBbC8TbQ1AM890

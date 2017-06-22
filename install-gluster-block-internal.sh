#!/bin/bash

dnf install glusterfs-server glusterfs-fuse -y
dnf copr enable pkalever/gluster-block -y
dnf install gluster-block gluster-block-debuginfo -y
dnf install iscsi-initiator-utils -y
mkdir /var/log/gluster-block/
dnf install kernel-modules -y

systemctl enable glusterd.service
systemctl enable gluster-blockd.service

reboot

#!/bin/bash
set -x

systemctl stop irqbalance
tuna -q "virtio4-input*" -c 2 -m -x
tuna -q "virtio4-output*" -c 1 -m -x
tuna -q "virtio5-input*" -c 2 -m -x
tuna -q "virtio5-output*" -c 1 -m -x
tuna -Q


#!/bin/bash

set -x

NIC1=eth0
NIC2=eth1

NIC1_PCI_ADDR=`ethtool -i $NIC1 | grep -Eo '[0-9]+:[0-9]+:[0-9]+\.[0-9]+'`
NIC2_PCI_ADDR=`ethtool -i $NIC2 | grep -Eo '[0-9]+:[0-9]+:[0-9]+\.[0-9]+'`

set -x

modprobe -r vfio_iommu_type1
modprobe -r vfio
modprobe vfio enable_unsafe_noiommu_mode=1
modprobe vfio-pci

dpdk-devbind -b vfio-pci $NIC1_PCI_ADDR
sleep 3
dpdk-devbind -b vfio-pci $NIC2_PCI_ADDR
sleep 3


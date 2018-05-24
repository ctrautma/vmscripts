#!/bin/bash

set -x

NIC1=eth1
NIC2=eth2

if [[ $# -eq 2 ]]; then
    NIC1=$1
    NIC2=$2
else if [[ $# -ne 0 ]]; then
    echo "Please pass Zero or Two parameters."
    exit 1
fi
fi

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



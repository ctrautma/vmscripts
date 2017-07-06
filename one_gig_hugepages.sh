set -x

echo $1 >  /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages

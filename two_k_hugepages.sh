set -x

sysctl vm.nr_hugepages=$1
mkdir -p /dev/hugepages
mount -t hugetlbfs hugetlbfs /dev/hugepages

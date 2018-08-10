set -x

VIOMMU="NO"
DPDK_BUILD="NO"

progname=$0

function usage () {
   cat <<EOF
Usage: $progname [-v enable viommu]
EOF
   exit 0
}

while getopts hvu FLAG; do
   case $FLAG in

   v)  echo "VIOMMU is enabled"
       VIOMMU="YES";;
   u)  echo "Building upstream DPDK"
       DPDK_BUILD="YES";;
   h)  echo "found $opt" ; usage ;;
   \?)  usage ;;
   esac
done

shift $(($OPTIND - 1))

yum install libibverbs -y

yum install -y nmap-ncat tcpdump

# netperf & iperf
yum install -y gcc-c++ make gcc

netperf=netperf-2.6.0
wget http://lacrosse.corp.redhat.com/~haliu/${netperf}.tar.gz -O /tmp/${netperf}.tar.gz
tar zxvf /tmp/${netperf}.tar.gz
pushd ${netperf}
# add support for IBM new system arch ppc64le
sed -i "/ppc64/i\ppc64le:Linux:*:*)\n\ echo powerpc64le-unknown-linux-gnu\n\ exit ;;" config.guess
./configure && make && make install
popd

IPERF_FILE="iperf-2.0.5.tar.gz"
wget http://lacrosse.corp.redhat.com/~haliu/${IPERF_FILE}
tar xf ${IPERF_FILE}
BUILD_DIR="${IPERF_FILE%.tar.gz}"
cd ${BUILD_DIR}
# add support for IBM new system arch ppc64le
sed -i "/ppc64/i\ppc64le:Linux:*:*)\n\ echo powerpc64le-unknown-linux-gnu\n\ exit ;;" config.guess
./configure && make && make install

rm -f ${IPERF_FILE}
rm -Rf IPERF*
rm -f ${netperf}.tar.gz
rm -Rf netperf*

mkdir -P /root/dpdkrpms/1705 /root/dpdkrpms/1611-2 /root/tuned/28 /root/tuned/27 /root/dpdkrpms/1711 /root/dpdkrpms/1611-4 /root/dpdkrpms/1711-8 /root/dpdkrpms/1711-9 /root/dpdkrpms/1711-13
SERVER="download-node-02.eng.bos.redhat.com"
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-cpu-partitioning-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-nfv-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-realtime-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.8.0/2.el7fdp/noarch/tuned-2.8.0-2.el7fdp.noarch.rpm -P /root/tuned/28/.
wget http://$SERVER/brewroot/packages/tuned/2.8.0/2.el7fdp/noarch/tuned-profiles-cpu-partitioning-2.8.0-2.el7fdp.noarch.rpm -P /root/tuned/28/.
wget http://$SERVER/brewroot/packages/dpdk/17.05/2.el7fdb/x86_64/dpdk-17.05-2.el7fdb.x86_64.rpm -P /root/dpdkrpms/1705/.
wget http://$SERVER/brewroot/packages/dpdk/17.05/2.el7fdb/x86_64/dpdk-tools-17.05-2.el7fdb.x86_64.rpm -P /root/dpdkrpms/1705/.
wget http://$SERVER/brewroot/packages/dpdk/16.11.2/4.el7/x86_64/dpdk-16.11.2-4.el7.x86_64.rpm -P /root/dpdkrpms/1611-2/.
wget http://$SERVER/brewroot/packages/dpdk/16.11.2/4.el7/x86_64/dpdk-tools-16.11.2-4.el7.x86_64.rpm -P /root/dpdkrpms/1611-2/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/7.el7/x86_64/dpdk-17.11-7.el7.x86_64.rpm -P /root/dpdkrpms/1711/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/7.el7/x86_64/dpdk-tools-17.11-7.el7.x86_64.rpm -P /root/dpdkrpms/1711/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/9.el7fdb/x86_64/dpdk-17.11-9.el7fdb.x86_64.rpm -P /root/dpdkrpms/1711-9/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/9.el7fdb/x86_64/dpdk-tools-17.11-9.el7fdb.x86_64.rpm -P /root/dpdkrpms/1711-9/.
wget http://$SERVER/brewroot/packages/dpdk/16.11/4.el7fdp/x86_64/dpdk-16.11-4.el7fdp.x86_64.rpm -P /root/dpdkrpms/1611-4/.
wget http://$SERVER/brewroot/packages/dpdk/16.11/4.el7fdp/x86_64/dpdk-tools-16.11-4.el7fdp.x86_64.rpm -P /root/dpdkrpms/1611-4/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/8.el7fdb/x86_64/dpdk-17.11-8.el7fdb.x86_64.rpm -P /root/dpdkrpms/1711-8/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/8.el7fdb/x86_64/dpdk-tools-17.11-8.el7fdb.x86_64.rpm -P /root/dpdkrpms/1711-8/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/13.el7/x86_64/dpdk-17.11-13.el7.x86_64.rpm -P /root/dpdkrpms/1711-13/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/13.el7/x86_64/dpdk-tools-17.11-13.el7.x86_64.rpm -P /root/dpdkrpms/1711-13/.

if [ "$DPDK_BUILD" == "YES" ]
then
    # install upstream dpdk version
    DPDK_VER="master"
    yum install -y kernel-devel numactl-devel git
    cd /root
    git clone git://dpdk.org/dpdk
    cd dpdk
    git checkout $DPDK_VER
    export RTE_TARGET=x86_64-native-linuxapp-gcc
    make install T=$RTE_TARGET
    cd ..
fi

# Detect OS name and version from systemd based os-release file
. /etc/os-release

if [ $VERSION_ID == "7.4" ] || [ $VERSION_ID == "7.3" ]
then
    rpm -Uvh /root/tuned/28/tuned-2.8.0-2.el7fdp.noarch.rpm
    rpm -ivh /root/tuned/28/tuned-profiles-cpu-partitioning-2.8.0-2.el7fdp.noarch.rpm
else
    yum install -y tuned-profiles-cpu-partitioning
fi

rpm -ivh http://$SERVER/brewroot/packages/driverctl/0.95/1.el7fdparch/noarch/driverctl-0.95-1.el7fdparch.noarch.rpm

# Isolated CPU list
ISOLCPUS=`lscpu | grep "NUMA node0" | awk '{print $4}'`

if [ `echo $ISOLCPUS | awk /'^0,'/` ]
    then
    ISOLCPUS=`echo $ISOLCPUS | cut -c 3-`
elif [ `echo $ISOLCPUS | awk /'^0-'/` ]
    then
    ISOLCPUS=`echo $ISOLCPUS | sed s/'^0-'/'1-'/`
fi
echo $ISOLCPUS

sed -i 's/\(GRUB_CMDLINE_LINUX.*\)"$/\1/g' /etc/default/grub
if [ "$VIOMMU" == "NO" ]; then
    sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
elif [ "$VIOMMU" == "YES" ]; then
    sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G intel_iommu=on nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
fi

echo -e "isolated_cores=$ISOLCPUS" >> /etc/tuned/cpu-partitioning-variables.conf
sed -i "s/GRUB_TERMINAL=\"serial console\"/GRUB_TERMINAL=\"console\"/" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
systemctl start tuned
sleep 10
tuned-adm profile cpu-partitioning

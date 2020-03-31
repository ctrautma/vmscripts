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


. /etc/os-release
rhel=$(echo $VERSION_ID | cut -d '.' -f 1)

if [ $rhel == 8 ]; then
    yum install -y http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/netperf/2.7.0/5.el8+5/x86_64/netperf-2.7.0-5.el8+5.x86_64.rpm

    yum install -y iperf3
else
    # Install python2 for dpdk bonding
    yum -y install python

    # Install netperf
    netperf=netperf-2.6.0
    wget http://lacrosse.corp.redhat.com/~haliu/${netperf}.tar.gz -O /tmp/${netperf}.tar.gz
    tar zxvf /tmp/${netperf}.tar.gz
    pushd ${netperf}
    # add support for IBM new system arch ppc64le
    sed -i "/ppc64/i\ppc64le:Linux:*:*)\n\ echo powerpc64le-unknown-linux-gnu\n\ exit ;;" config.guess
    ./configure && make && make install
    popd

    # Install iperf
    IPERF_FILE="iperf-2.0.5.tar.gz"
    wget http://lacrosse.corp.redhat.com/~haliu/${IPERF_FILE}
    tar xf ${IPERF_FILE}
    BUILD_DIR="${IPERF_FILE%.tar.gz}"
    cd ${BUILD_DIR}
    # add support for IBM new system arch ppc64le
    sed -i "/ppc64/i\ppc64le:Linux:*:*)\n\ echo powerpc64le-unknown-linux-gnu\n\ exit ;;" config.guess
    ./configure && make && make install
    cd ..

    #Cleanup directories
    rm -f ${IPERF_FILE}
    rm -Rf IPERF*
    rm -f ${netperf}.tar.gz
    rm -Rf netperf*
fi


# DPDK Rpms download and tuned profiles download
SERVER="download-node-02.eng.bos.redhat.com"
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-cpu-partitioning-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-nfv-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.7.1/5.el7fdb/noarch/tuned-profiles-realtime-2.7.1-5.el7fdb.noarch.rpm -P /root/tuned/27/.
wget http://$SERVER/brewroot/packages/tuned/2.8.0/2.el7fdp/noarch/tuned-2.8.0-2.el7fdp.noarch.rpm -P /root/tuned/28/.
wget http://$SERVER/brewroot/packages/tuned/2.8.0/2.el7fdp/noarch/tuned-profiles-cpu-partitioning-2.8.0-2.el7fdp.noarch.rpm -P /root/tuned/28/.
# DO NOT REMOVE THIS REQUIRED FOR PFT
mkdir -p /root/dpdkrpms/1711-15
wget http://$SERVER/brewroot/packages/dpdk/17.11/15.el7/x86_64/dpdk-17.11-15.el7.x86_64.rpm -P /root/dpdkrpms/1711-15/.
wget http://$SERVER/brewroot/packages/dpdk/17.11/15.el7/x86_64/dpdk-tools-17.11-15.el7.x86_64.rpm -P /root/dpdkrpms/1711-15/.
# DO NOT REMOVE THIS, REQUIRED for PFT
mkdir -p /root/dpdkrpms/17-11-13
wget http://$SERVER/brewroot/packages/dpdk/17.11/13.el7/x86_64/dpdk-17.11-13.el7.x86_64.rpm -P /root/dpdkrpms/17-11-13
wget http://$SERVER/brewroot/packages/dpdk/17.11/13.el7/x86_64/dpdk-tools-17.11-13.el7.x86_64.rpm -P /root/dpdkrpms/17-11-13
mkdir -p /root/dpdkrpms/17-11-14
wget http://$SERVER/brewroot/packages/dpdk/17.11/14.el8/x86_64/dpdk-17.11-14.el8.x86_64.rpm -P /root/dpdkrpms/17-11-14
wget http://$SERVER/brewroot/packages/dpdk/17.11/14.el8/x86_64/dpdk-tools-17.11-14.el8.x86_64.rpm -P /root/dpdkrpms/17-11-14
mkdir -p /root/dpdkrpms/1811-2
wget http://$SERVER/brewroot/packages/dpdk/18.11/2.el7_6/x86_64/dpdk-18.11-2.el7_6.x86_64.rpm -P /root/dpdkrpms/1811-2/.
wget http://$SERVER/brewroot/packages/dpdk/18.11/2.el7_6/x86_64/dpdk-tools-18.11-2.el7_6.x86_64.rpm -P /root/dpdkrpms/1811-2/.
mkdir -p /root/dpdkrpms/el8-1811-2
wget http://$SERVER/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-18.11-2.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-2/.
wget http://$SERVER/brewroot/packages/dpdk/18.11/2.el8/x86_64/dpdk-tools-18.11-2.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-2/.

mkdir -p /root/dpdkrpms/el8-1811-2-3
wget http://$SERVER/brewroot/packages/dpdk/18.11.2/3.el8/x86_64/dpdk-18.11.2-3.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-2-3/.
wget http://$SERVER/brewroot/packages/dpdk/18.11.2/3.el8/x86_64/dpdk-tools-18.11.2-3.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-2-3/.

mkdir -p /root/dpdkrpms/1811-4
wget http://$SERVER/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-18.11-4.el7_6.x86_64.rpm -P /root/dpdkrpms/1811-4/.
wget http://$SERVER/brewroot/packages/dpdk/18.11/4.el7_6/x86_64/dpdk-tools-18.11-4.el7_6.x86_64.rpm -P /root/dpdkrpms/1811-4/.
mkdir -p /root/dpdkrpms/el8-1811-4
wget http://$SERVER/brewroot/packages/dpdk/18.11/4.el8/x86_64/dpdk-18.11-4.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-4/.
wget http://$SERVER/brewroot/packages/dpdk/18.11/4.el8/x86_64/dpdk-tools-18.11-4.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-4/.

mkdir -p /root/dpdkrpms/el8-1811-8
wget http://$SERVER/brewroot/packages/dpdk/18.11/8.el8/x86_64/dpdk-18.11-8.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-8/.
wget http://$SERVER/brewroot/packages/dpdk/18.11/8.el8/x86_64/dpdk-tools-18.11-8.el8.x86_64.rpm -P /root/dpdkrpms/el8-1811-8/.

mkdir -p /root/dpdkrpms/el8-1911-2
wget http://$SERVER/brewroot/packages/dpdk/19.11/2.el8/x86_64/dpdk-19.11-2.el8.x86_64.rpm -P /root/dpdkrpms/el8-1911-2/.
wget http://$SERVER/brewroot/packages/dpdk/19.11/2.el8/x86_64/dpdk-tools-19.11-2.el8.x86_64.rpm -P /root/dpdkrpms/el8-1911-2/.

mkdir -p /root/dpdkrpms/el8-1911-4
wget http://$SERVER/brewroot/packages/dpdk/19.11/4.el8/x86_64/dpdk-19.11-4.el8.x86_64.rpm -P /root/dpdkrpms/el8-1911-4/.
wget http://$SERVER/brewroot/packages/dpdk/19.11/4.el8/x86_64/dpdk-tools-19.11-4.el8.x86_64.rpm -P /root/dpdkrpms/el8-1911-4/.

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

SYSTEM_VERSION_ID=`echo $VERSION_ID | tr -d '.'`
if (( $SYSTEM_VERSION_ID < 80 ))
then
    sed -i 's/\(GRUB_CMDLINE_LINUX.*\)"$/\1/g' /etc/default/grub
    if [ "$VIOMMU" == "NO" ]; then
        sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
    elif [ "$VIOMMU" == "YES" ]; then
        sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G intel_iommu=on iommu=pt nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
    fi


    echo -e "isolated_cores=$ISOLCPUS" >> /etc/tuned/cpu-partitioning-variables.conf
    sed -i "s/GRUB_TERMINAL=\"serial console\"/GRUB_TERMINAL=\"console\"/" /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    systemctl start tuned
    sleep 10
    tuned-adm profile cpu-partitioning
else
    # to save the old options, and remove
    kernelopts=$(grub2-editenv - list | grep kernelopts | cut -d '=' -f2-)
    # append
    if [ "$VIOMMU" == "NO" ]; then
        #grub2-editenv - set kernelopts="$kernelopts default_hugepagesz=1G hugepagesz=1G nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup"
        grub2-editenv - set kernelopts="$kernelopts isolcpus=$ISOLCPUS default_hugepagesz=1G hugepagesz=1G hugepages=2"
	#sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
    elif [ "$VIOMMU" == "YES" ]; then
        grub2-editenv - set kernelopts="$kernelopts default_hugepagesz=1G hugepagesz=1G intel_iommu=on iommu=pt nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup"
        #sed -i "s/GRUB_CMDLINE_LINUX.*/& default_hugepagesz=1G hugepagesz=1G intel_iommu=on nohz=on nohz_full=$ISOLCPUS rcu_nocbs=$ISOLCPUS tuned.non_isolcpus=00000001 intel_pstate=disable nosoftlockup\"/g" /etc/default/grub
    fi
    systemctl start tuned
    sleep 10
    echo -e "isolated_cores=$ISOLCPUS" >> /etc/tuned/cpu-partitioning-variables.conf
    tuned-adm profile cpu-partitioning
    #grub2-editenv - set kernelopts="$kernelopts iommu=on iommu=pt default_hugepagesz=1GB hugepagesz=1G hugepages=16"
    # to check
    #cat /boot/grub2/grubenv for Legacy BIOS or ppc64 systems
    #cat /boot/efi/EFI/redhat/grubenv for EFI systems

fi

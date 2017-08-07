#!/bin/bash

NBCORES=2
QUEUES=1
CPUS=3
DESCRIPTORS=2048
MEMORY="1024"
FORWARD="io"
AUTOSTART="--auto-start"
NICS=""

progname=$0

function usage () {
   cat <<EOF
Usage: $progname [-c cpus] [-n nb-cores] [-q queues] [-m socket memory] [-d descriptors] [-w "whitelisted nic" do multiple -w for multiple nics] [-f forward mode] [-u disable auto start]
EOF
   exit 0
}

while getopts c:n:q:m:d:f:w:uh FLAG; do
   case $FLAG in

   c)  echo "Using $OPTARG cpus"
       CPUS=$OPTARG
       ;;
   n)  echo "nb-cores $OPTARG"
       NBCORES=$OPTARG
       ;;
   q)  echo "queues $OPTARG"
       QUEUES=$OPTARG
       ;;
   m)  echo "socket memory $OPTARG"
       MEMORY=$OPTARG
       ;;
   d)  echo "descriptors $OPTARG"
       DESCRIPTORS=$OPTARG
       ;;
   f)  echo "forward mode $OPTARG"
       FORWARD=$OPTARG
       ;;
   w)  NICS+="-w $OPTARG "
       echo "Whitelisted nic $OPTARG"
       ;;
   u)  echo "Autostart $OPTARG"
       AUTOSTART=""
       ;;
   h)  echo "found $opt" ; usage ;;
   \?)  usage ;;
   esac
done

shift $(($OPTIND - 1))

# create CPU mask from CPUS
((CPUS--))
MASK=`seq -s, 0 $CPUS`

set -x

testpmd -l $MASK -n4 --socket-mem $MEMORY $NICS -- \
--burst=64 -i --txqflags=0xf00 \
--rxd=$DESCRIPTORS --txd=$DESCRIPTORS \
--nb-cores=$NBCORES --rxq=$QUEUES --txq=$QUEUES \
--disable-hw-vlan --disable-rss --forward-mode=$FORWARD \
$AUTOSTART
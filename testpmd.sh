NBCORES=2
QUEUES=1
CPUS=3
DESCRIPTORS=2048


# create CPU mask from CPUS
((CPUS--))
MASK=`seq -s, 0 $CPUS`

testpmd -l $MASK -n4 --socket-mem 1024 -- \
--burst=64 -i --txqflags=0xf00 \
--rxd=$DESCRIPTORS --txd=$DESCRIPTORS \
--nb-cores=$NBCORES --rxq=$QUEUES --txq=$QUEUES \
--disable-hw-vlan --disable-rss

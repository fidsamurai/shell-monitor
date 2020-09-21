#! /bin/bash

###Insert Name of Instance(Project/Name of Instance)###

name=""

###Email List###
#Space seperated email list

emails="" 

###CPU Alerts###

cpu=`cat /proc/loadavg | awk '{print $1}'`
cput=1.00  ###Adjust according to CPU cores
cpua=`echo "$cpu > $cput" | bc -l`

if (( $cpua >= 1 ));
then echo "$name CPU Warning, CPU load at $cpu" | mail -s "$name CPU Warning" $emails
fi


###Memory Alerts###

mem=`free -m | grep Mem | awk '{print $7}'`
mema=500
#memw=300

#if (( $memw >= $mem ));
#then systemctl restart httpd 
#ipcs -s | awk -v user=apache '$3==user {system("ipcrm -s "$2)}'
#fi

if (( $mema >= $mem ));
then echo "$name Memory Warning, Memory at $mem MB" | mail -s "$name Memory Warning" $emails
fi

###Storage Alerts###

#Name of root partition
root=/dev/nvme0n1p1 #Set according to server

sto=`df -BM | grep $root | awk '{print $4}' | sed 's/M//g'`
stoa=2048

if (( $stoa >= $sto ));
then echo "$name Storage Warning, Storage at $sto MB" | mail -s "$name Storage Warning" $emails
fi

###2nd Partition if needed###
#part=
#stop=`df -BM | grep $part | awk '{print $4}' | sed 's/M//g'`

#if (( $stop >= $stoa ));
#then echo "$name Storage Warning $part, Storage at $stop" | mail -s "$name $part storage warning" $emails
#fi

###Network Alerts###

#Interface
if=ens5   #Set according to internet facing interface
rxa=1500
txa=1500
runtime="1 second"
endtime=$(date -ud "$runtime" +%s)

while [[ $(date -u +%s) -le $endtime ]]
do
rx=`cat /sys/class/net/$if/statistics/rx_bytes`
tx=`cat /sys/class/net/$if/statistics/tx_bytes`
sleep 1
rx2=`cat /sys/class/net/$if/statistics/rx_bytes`
tx2=`cat /sys/class/net/$if/statistics/tx_bytes`
RBPS=`expr $rx2 - $rx`
TBPS=`expr $tx2 - $tx`
TKBPS=`expr $TBPS / 1024`
RKBPS=`expr $RBPS / 1024`
#echo "tx $if: $TKBPS kb/s rx $if: $RKBPS kb/s"
done

if (( $RKBPS >= $rxa )); then
echo "$name Network Incoming Usage Warning, Incoming at $RKBPS kb/s" | mail -s "$name Network Incoming Warning" $emails
fi

if (( $TKBPS >= $txa )); then
echo "$name Network Outgoing Usage Warning, Outgoing at $TKBPS kb/s" | mail -s "$name Network Outgoing Warning" $emails
fi


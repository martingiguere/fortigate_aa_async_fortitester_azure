#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Wait for Internet access through the FGTs"
while ! curl --connect-timeout 3 "http://www.google.com" &> /dev/null
    do continue
done
apt-get update -y
#install iperf
apt-get install -y iperf
#install iperf3
apt-get install -y iperf3
iperf3 --server --daemon --logfile /var/log/iperf3.txt --pidfile /run/iperf3.pid
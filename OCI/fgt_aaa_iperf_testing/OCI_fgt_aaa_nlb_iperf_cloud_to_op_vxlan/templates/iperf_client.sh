#!/bin/bash

# Install iperf3
apt-get update
apt-get install -y iperf3

# Disable Ubuntu OCI iptables default
iptables -F
netfilter-persistent save

# Script to run iperf3 each 60 seconds
cat <<EOF > /home/ubuntu/iperf.sh
#!/bin/bash

# Infinite loop to run iperf3 every 60 seconds
while true; do
    # Run iperf3 with the random port
    iperf3 -P${parallels} -c${server_ip} -w${window}

    # Wait ${loop_time} before running iperf3 again
    sleep ${loop_time}
done
EOF

# Give execute permition
chmod +x /home/ubuntu/iperf.sh
# Execute script
/home/ubuntu/iperf.sh
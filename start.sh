#!/bin/bash
echo "[*] Enabling IP Forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "[*] Creating NAT Port Forwards..."
iptables -t nat -A PREROUTING -p tcp --dport 6069 -j DNAT --to-destination 192.168.122.69:8443
iptables -t nat -A PREROUTING -p tcp --dport 6070 -j DNAT --to-destination 192.168.122.70:443
iptables -t nat -A PREROUTING -p tcp --dport 6071 -j DNAT --to-destination 192.168.122.71:443

echo "[*] Creating Local Loopback NAT (for testing on Kali)..."
iptables -t nat -A OUTPUT -p tcp -d 10.15.16.98 --dport 6069 -j DNAT --to-destination 192.168.122.69:8443
iptables -t nat -A OUTPUT -p tcp -d 10.15.16.98 --dport 6070 -j DNAT --to-destination 192.168.122.70:443
iptables -t nat -A OUTPUT -p tcp -d 10.15.16.98 --dport 6071 -j DNAT --to-destination 192.168.122.71:443

echo "[*] Applying SNAT Masquerade..."
iptables -t nat -A POSTROUTING -p tcp -d 192.168.122.69 --dport 8443 -j MASQUERADE
iptables -t nat -A POSTROUTING -p tcp -d 192.168.122.70 --dport 443 -j MASQUERADE
iptables -t nat -A POSTROUTING -p tcp -d 192.168.122.71 --dport 443 -j MASQUERADE

echo "[*] Punching through KVM Forwarding Block..."
iptables -I FORWARD 1 -p tcp -d 192.168.122.69 --dport 8443 -j ACCEPT
iptables -I FORWARD 1 -p tcp -d 192.168.122.70 --dport 443 -j ACCEPT
iptables -I FORWARD 1 -p tcp -d 192.168.122.71 --dport 443 -j ACCEPT

echo "[+] Fortinet SOC Gateway is LIVE!"

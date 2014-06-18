#!/bin/bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo ifconfig wlan0 192.168.137.1
sudo service dnsmasq restart
sudo hostapd /etc/hostapd/hostapd.conf

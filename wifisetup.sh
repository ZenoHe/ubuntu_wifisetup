#!/bin/bash
# Description: Set up wifi
# Filename: wifisetup.sh
# Checking if the interface support ap mode.
set -e #Exit whenever error occurs.
trap 'echo -e "Exit not abnormally.\nPlease check if you run this script as root."' INT TERM EXIT
echo -n "Check if the interface support ap mode...  "
a=`iw list | grep "Supported interface modes" -A 4 | egrep "AP$"`
if test -z "$a"; then
    echo -e "[\e[1;31mNot supported\e[0m]"
    exit -1
else
    echo -e "[\e[1;31mSupported\e[0m]"
fi
# Checking if your provide the needed.
if [ $# -ne 4 ]
then
    echo -e "Please run this script as root.\nUsage: $0 -s <ssid> -k <key>"
    exit -1
fi
for i in {1..4}
do
    case $1 in
        -s) shift; ssid=$1; shift ;;
        -k) shift; key=$1; shift;; 
    esac
done
#check if the dnsmasq installed.
installed_dnsmasq=`dpkg --get-selections dnsmasq | grep install`
if [ -z "$installed_dnsmasq" ]; then 
    apt-get install dnsmasq 
    cat dnsmasq_conf > /etc/dnsmasq.conf
else
    echo "Already have dnsmasq installed"
fi
# Check if hostapd installed.
installed_hostapd=`dpkg --get-selections hostapd | grep install`
if [ -z "$installed_hostapd" ]; then
    apt-get install hostapd
else
    echo "Already have hostapd installed."
    echo -n "Changing the ssid and passphrase..."
fi
cat ./hostapd_conf | sed -e "s/wpa_passphrase=/&$key/" -e "s/ssid=/&$ssid/" > /etc/hostapd/hostapd.conf
if [ $? = 0 ]; then
    echo -e "[\e[1;31mSucceed\e[0m]"
else
    echo -e "[\e[1;31mFailed\e[0m]"
fi
echo "1" > /proc/sys/net/ipv4/ip_forward
# Check /etc/sysctl.conf
sysctl_check=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward=1"`
if test -z "$sysctl_check"; then
    echo "Setting up /etc/sysctl.conf..."
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
else
    echo "Already set up /etc/sysctl.conf."
fi
echo -e "All done!\nNow run the startwifi.sh in the same folder with this script"

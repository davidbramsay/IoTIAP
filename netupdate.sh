sed -i '/^#auto wlan0/s/^#auto wlan0/auto ra0/' /etc/network/interfaces
sed -i '/^#iface wlan0/s/^#iface wlan0 inet dhcp/iface ra0 inet dhcp/' /etc/network/interfaces
sed -i '/^#.*wpa-ssid/s/^#.*$/wireless-essid "MIT GUEST"/' /etc/network/interfaces
apt-get install -y avahi-discover libnss-mdns
apt-get update
apt-get install -y curl
curl https://gist.githubusercontent.com/anonymous/c31234b1756b8877fe41/raw/a85da8f6a695534d10385bdf0cc53b89c24c952e/ssh.service > /etc/avahi/services/ssh.service
sed -i "s/XXXXXXXX/`cat /sys/devices/bone_capemgr.*/baseboard/serial-number`/" /etc/avahi/services/ssh.service 
systemctl restart avahi-daemon.service
sed -i "s/^exit 0/dart \/root\/send_net_info.dart \&\nexit 0/" /etc/rc.local

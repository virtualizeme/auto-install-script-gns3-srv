#!/bin/bash


clear
echo "Update oraz Upgrade Ubuntu"

# dwie ponizsze linie wylaczaja pytanie o restart serwisow przy kazdorazowym apt update i apt install z uwagi na fuul-upgrade nie sa potrzebne
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sleep 2

apt update -y
sleep 1
apt full-upgrade -y --auto-remove
sleep 1

clear
echo "Dodanie repozytorium GNS3 oraz instalacja GNS3 gui i GNS3 server"
sleep 2

add-apt-repository ppa:gns3/ppa -y
sleep 1
apt update -y
sleep 1
# wlaczenie trybu bez interakcji uzytkownika, co nie pozwoli uzytkownikom non-root do wykonania capture packet oraz dodania do grupy wireshark
#DEBIAN_FRONTEND=noninteractive apt -y install gns3-gui gns3-server ==> chwilowo usuniete do instalacji testing 
DEBIAN_FRONTEND=noninteractive apt -y install gns3-server
sleep 1

clear
echo "Dodanie wsparcia architektury i386 dla IOU"
sleep 2
# zmiana hostname serwera ktora zostanie przypisana do licencji IOU
hostnamectl set-hostname gns3server
sleep 1
dpkg --add-architecture i386
sleep 1
apt update -y
sleep 1
apt install gns3-iou -y
sleep 1

#################### ta czesc odpowiada za konfiguracje serwera i uzytkownika gns3 #########################

# wpisanie do zmiennej uzytkownika instalujacego serwer
USER="$(whoami)"

# utworzenie uzytkownika gns3 i przypisanie mu folderu domowego 
useradd -d /opt/gns3/ -m gns3

# konfiguracja serwera gns3
mkdir -p /etc/gns3
cat <<EOFC > /etc/gns3/gns3_server.conf
[Server]
host = $(hostname  -I | cut -f1 -d' ')
port = 3080 
images_path = /opt/gns3/images
projects_path = /opt/gns3/projects
appliances_path = /opt/gns3/appliances
configs_path = /opt/gns3/configs
report_errors = True
[Qemu]
enable_hardware_acceleration = True
require_hardware_acceleration = True
EOFC

chown -R $USER:gns3 /etc/gns3 
chown -R gns3:gns3 /etc/gns3
chmod -R 700 /etc/gns3

cat <<EOFI > /etc/init/gns3.conf
description "GNS3 server"
author      "GNS3 Team"
start on filesystem or runlevel [2345]
stop on runlevel [016]
respawn
console log
script
    exec start-stop-daemon --start --make-pidfile --pidfile /var/run/gns3.pid --chuid gns3 --exec "/usr/bin/gns3server"
end script
pre-start script
    echo "" > /var/log/upstart/gns3.log
    echo "[`date`] GNS3 Starting"
end script
pre-stop script
    echo "[`date`] GNS3 Stopping"
end script
EOFI

chown root:root /etc/init/gns3.conf
chmod 644 /etc/init/gns3.conf

sudo systemctl stop gns3server.service
sleep 1 
sudo systemctl start gns3server.service
sleep 2


# instalacja serwisu systemd

cat <<EOFI > /lib/systemd/system/gns3.service
[Unit]
Description=GNS3 server
After=network-online.target
Wants=network-online.target
Conflicts=shutdown.target
[Service]
User=gns3
Group=gns3
PermissionsStartOnly=true
EnvironmentFile=/etc/environment
ExecStartPre=/bin/mkdir -p /var/log/gns3 /var/run/gns3
ExecStartPre=/bin/chown -R gns3:gns3 /var/log/gns3 /var/run/gns3
ExecStart=/usr/bin/gns3server --log /var/log/gns3/gns3.log
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=16384
[Install]
WantedBy=multi-user.target
EOFI
chmod 755 /lib/systemd/system/gns3.service
chown root:root /lib/systemd/system/gns3.service

sudo systemctl enable gns3server.service
sudo systemctl start gns3server.service


# pobranie skryptu do utowrzenia licencji dla IOU, zmiana nazwy pliku i przeniesienie go do konfiguracji gns3
wget http://www.ipvanquish.com/download/CiscoIOUKeygen3f.py
python3 ./CiscoIOUKeygen3f.py
mv iourc.txt /opt/gns3/.iourc
chmod +x /opt/gns3/images/IOU/*.*



clear
echo "Instalacja Docker-CE"
sleep 2

apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt-cache policy docker-ce
apt install docker-ce -y


clear
echo "Dodanie uzytkownika gns3 do grup  ubridge,libvirt,kvm,docker i nadanie uprawnien"
sleep 2

usermod -aG ubridge gns3
usermod -aG libvirt gns3
usermod -aG kvm gns3
# usermod -aG wireshark $USER ==> wpis nie aktywny z uwagi na tryb NOINTERACTIVE instalacji gns3server
usermod -aG docker gns3
sleep 3

clear
echo "Uruchomienie serwisow GNS3 i Docker oraz dodanie do uruchamiania z startem systemu"
sudo systemctl restart gns3server.service
sleep 2
sudo systemctl restart docker
sleep 2
sudo systemctl enable docker
sleep 2
sudo systemctl enable gns3server.service
sleep 2


clear
echo "Status serwisow GN3 i Docker"
echo "#######################################"
echo "GNS3: $(sudo systemctl status gns3server.service | grep Active:)"
echo "Docker-CE: $(sudo systemctl status docker | grep Active:)"
echo "#######################################"
echo "GNS3 web portal: http://$(hostname  -I | cut -f1 -d' '):3080"
echo "#######################################"
read -p "Instalacja zakonczona, wcisniej ENTER..nastapi REBOOT systemu"
shutdown -r now

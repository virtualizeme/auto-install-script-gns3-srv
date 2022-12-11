#!/bin/bash


clear
echo "Zmiana nazwy hostname na 'gns3server'"
hostnamectl set-hostname gns3server
sleep 2

clear
echo "Update oraz Upgrade Ubuntu oraz wylaczenie kernel promtp i sevices restart prompt"
sleep 2
# dwie ponizsze linie wylaczaja pytanie o restart serwisow przy kazdorazowym apt update i apt install z uwagi na fuul-upgrade nie sa potrzebne
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
sleep 1
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sleep 1
apt update -y
sleep 1
apt full-upgrade -y --auto-remove
sleep 1


clear
echo "Dodanie repozytorium GNS3 oraz instalacja GNS3 server"
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
dpkg --add-architecture i386
sleep 1
apt update -y
sleep 1
apt install gns3-iou -y
sleep 1

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
echo "Dodanie uzytkownika biezacego uzytkownika do grup"
sleep 2

usermod -aG ubridge ubuntu
usermod -aG libvirt ubuntu
usermod -aG kvm ubuntu
# usermod -aG wireshark $USER ==> wpis nie aktywny z uwagi na tryb NOINTERACTIVE instalacji gns3server
usermod -aG docker ubuntu
sleep 3

#################### ta czesc odpowiada za konfiguracje serwera i uzytkownika gns3 #########################




clear
echo "Konfiguracja serwera i uzytkownika gns3"


echo "wylaczenie servera gns3 do wprowadzenia wlasnej konfiguracji"
systemctl stop gns3server.service
sleep 2

echo "stworzenie folderow wskazanych w pliku konfiguracyjnym i nadanie uprawnien"
sessionPath=$(pwd)
mkdir -p $sessionPath/gns3
chown -R ubuntu:ubuntu /$sessionPath/gns3
chmod -R 700 /$sessionPath/gns3

echo "stworzenie folderu gns3 w /etc i nadanie uprawnien"
# konfiguracja serwera gns3
mkdir -p /etc/gns3
chown -R ubuntu:ubuntu /etc/gns3
chmod -R 700 /etc/gns3

echo "stworzenie w /etc/gns3/... pliku konfiguracyjnego"
cat <<EOFC > /etc/gns3/gns3_server.conf
[Server]
host = 0.0.0.0
port = 3080 
images_path = $sessionPath/gns3/images
projects_path = $sessionPath/gns3/projects
appliances_path = $sessionPath/gns3/appliances
configs_path = $sessionPath/gns3/configs
report_errors = True
console_start_port_range = 5000
console_end_port_range = 5800
vnc_console_start_port_range = 5900
vnc_console_end_port_range = 10000
udp_start_port_range = 20000
udp_end_port_range = 30000
auth = True
user = admin
password = admin
enable_builtin_templates = True
[Dynamips]
allocate_aux_console_ports = False
mmap_support = True
dynamips_path = $sessionPath/gns3/images/IOS
sparse_memory_support = True
ghost_ios_support = True
[IOU]
iouyap_path = $sessionPath/gns3/images/IOU
iourc_path = $sessionPath/gns3/.iourc
license_check = True
[Qemu]
enable_kvm = True
require_kvm = True
enable_hardware_acceleration = True
require_hardware_acceleration = True
EOFC

echo "dodanie do startu systemu docker i gns3server systemctl enable"
systemctl enable gns3server.service
systemctl enable docker
sleep 1

echo "ponowne uruchomienie serwera gns z nowymi ustawieniami"
systemctl start gns3server.service
sleep 2


echo "Tworzenie pliku CiscoIOUKeygen.py"
cat <<EOFC > CiscoIOUKeygen.py
#! /usr/bin/python3
print("*********************************************************************")
print("Cisco IOU License Generator - Kal 2011, python port of 2006 C version")
import os
import socket
import hashlib
import struct
# get the host id and host name to calculate the hostkey
hostid=os.popen("hostid").read().strip()
hostname = socket.gethostname()
ioukey=int(hostid,16)
for x in hostname:
 ioukey = ioukey + ord(x)
print("hostid=" + hostid +", hostname="+ hostname + ", ioukey=" + hex(ioukey)[2:])
# create the license using md5sum
iouPad1 = b'\x4B\x58\x21\x81\x56\x7B\x0D\xF3\x21\x43\x9B\x7E\xAC\x1D\xE6\x8A'
iouPad2 = b'\x80' + 39*b'\0'
md5input=iouPad1 + iouPad2 + struct.pack('!L', ioukey) + iouPad1
iouLicense=hashlib.md5(md5input).hexdigest()[:16]
print("\nAdd the following text to ~/.iourc:")
print("[license]\n" + hostname + " = " + iouLicense + ";\n")
with open("iourc.txt", "wt") as out_file:
   out_file.write("[license]\n" + hostname + " = " + iouLicense + ";\n")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\nAlready copy to the file iourc.txt\n ")
print("You can disable the phone home feature with something like:")
print(" echo '127.0.0.127 xml.cisco.com' >> /etc/hosts\n")
EOFC

sleep 1


echo "Instalacja licencji IOU"

chmod +x CiscoIOUKeygen.py
python3 ./CiscoIOUKeygen.py

mv iourc.txt $sessionPath/gns3/.iourc
cp /$sessionPath/gns3/.iourc /$sessionPath/gns3/images/



echo "Status serwisow GN3 i Docker"
echo "#######################################"
echo "GNS3: $(sudo systemctl status gns3server.service | grep Active:)"
echo "Docker-CE: $(sudo systemctl status docker | grep Active:)"
echo "#######################################"
echo "GNS3 web portal: http://$(hostname  -I | cut -f1 -d' '):3080"
echo "#######################################"
read -p "Instalacja zakonczona, wcisniej ENTER..nastapi REBOOT systemu"
shutdown -r now

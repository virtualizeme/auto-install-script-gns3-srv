#!/bin/bash


clear
echo "Update oraz Upgrade Ubuntu"
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
apt install gns3-gui gns3-server -y
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
echo "Dodanie biezacego uzytkownika do grup  ubridge,libvirt,kvm,wireshark,docker"
sleep 2

USER="$(whoami)"
usermod -aG ubridge $USER
usermod -aG libvirt $USER
usermod -aG kvm $USER
usermod -aG wireshark $USER
usermod -aG docker $USER
sleep4

clear
echo "Uruchomienie serwisow GNS3 i Docker oraz dodanie do uruchamiania z startem systemu"
sudo systemctl start gns3server.service
sleep 2
sudo systemctl start docker
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
read -p "Instalacja zakonczona, wcisniej ENTER.."

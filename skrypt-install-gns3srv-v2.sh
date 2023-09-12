#!/bin/bash

# Sprawdzenie, czy skrypt jest uruchomiony z uprawnieniami roota
if [[ $EUID -ne 0 ]]; then
   echo "Ten skrypt musi być uruchomiony z uprawnieniami roota"
   exit 1
fi

sessionUser=$(logname)
sessionPath=$(pwd)

# Funkcje

update_and_upgrade() {
    echo "Update oraz Upgrade Ubuntu oraz wyłączenie kernel promtp i services restart prompt"
    sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
    sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
    apt update -y && apt full-upgrade -y --auto-remove
}

install_gns3() {
    echo "Dodanie repozytorium GNS3 oraz instalacja GNS3 server"
    add-apt-repository ppa:gns3/ppa -y
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt -y install gns3-server
}

install_iou_support() {
    echo "Dodanie wsparcia architektury i386 dla IOU"
    dpkg --add-architecture i386
    apt update -y
    apt install gns3-iou -y
}

install_docker() {
    echo "Instalacja Docker-CE"
    apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update -y
    apt install docker-ce -y
}

add_user_to_groups() {
    echo "Dodanie bieżącego użytkownika do grup"
    usermod -aG ubridge $sessionUser
    usermod -aG libvirt $sessionUser
    usermod -aG kvm $sessionUser
    usermod -aG docker $sessionUser
}

configure_gns3_server() {
    echo "Konfiguracja serwera i użytkownika gns3"
    systemctl stop gns3server.service
    mkdir -p $sessionPath/gns3
    chown -R $sessionUser:$sessionUser /$sessionPath/gns3
    chmod -R 700 /$sessionPath/gns3

    mkdir -p /etc/gns3
    chown -R $sessionUser:$sessionUser /etc/gns3
    chmod -R 700 /etc/gns3

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

    systemctl enable gns3server.service
    systemctl enable docker
    systemctl start gns3server.service
}

install_iou_license() {
    echo "Instalacja licencji IOU"
    cat <<EOFC > CiscoIOUKeygen.py
    # ... cała zawartość pliku CiscoIOUKeygen.py ...
EOFC

    chmod +x CiscoIOUKeygen.py
    python3 ./CiscoIOUKeygen.py

    mv iourc.txt $sessionPath/gns3/.iourc
    cp /$sessionPath/gns3/.iourc /$sessionPath/gns3/images/
}

# Główna część skryptu

update_and_upgrade
install_gns3
install_iou_support
install_docker
add_user_to_groups
configure_gns3_server
install_iou_license

echo "Status serwisów GN3 i Docker"
echo "GNS3: $(sudo systemctl status gns3server.service | grep Active:)"
echo "Docker-CE: $(sudo systemctl status docker | grep Active:)"
echo "GNS3 web portal: http://$(hostname  -I | cut -f1 -d' '):3080"
read -p "Instalacja zakończona, wciśnij ENTER.. nastąpi REBOOT systemu"
shutdown -r now

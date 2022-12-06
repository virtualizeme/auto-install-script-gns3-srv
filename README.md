# GNS3 - jako środowisko laboratoryjne
## GNS3 na Ubuntu Server 22.0.4 jako cyber-range dla zespolow RED-GREEN-BLUE
* wygodniejszy dostęp otrzymasz z uruchomionym serwerem SSH
* zrób update i upgrade swojej dystrybucji 
`$ sudo apt get update`

`$ sudo apt get upgrade`

### Instalacja serwera GNS3 z webGUI
* dodanie repozytorium GNS3
** po wyświetleniu informacji, czy użytkownicy inni niż root powinni mieć możliwość korzystania z wireshark i ubridge, wybierz „Tak” w obu przypadkach), wybór "Nie" będzie skutkować brakiem możliwości dodania do systemowych grup GNS'a. 
Paczka IOU musi zostać doinstalowana, wsparcie dla Dynamips jest zawarte w GNS3.
Można również doinstalować przez CLI VirtualBox lub vMware Player lub Workstation.
```
$ sudo add-apt-repository ppa:gns3/ppa
$ sudo apt update                                
$ sudo apt install gns3-gui gns3-server
```
* instalacja wsparcia do obsługi obrazów urządzeń sieciowych Cisco na IOU (architektura i386)
```
$ sudo dpkg --add-architecture i386
$ sudo apt update
$ sudo apt install gns3-iou
```
* instalacja docker engine dla kontenerów (Docker-ce) - community edition
```
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt update
```
```
$ apt-cache policy docker-ce
```
Output:
```
docker-ce:
  Zainstalowana: (brak)
  Kandydująca:   5:20.10.21~3-0~ubuntu-jammy
  Tabela wersji:
     5:20.10.21~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.20~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.19~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.18~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.17~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.16~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.15~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.14~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.13~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
```
Instalacja docker engine
```
$ sudo apt install docker-ce
```
* dodanie naszego użytkownika do grup usług dla serwisu GNS tj. `ubridge libvirt kvm wireshark docker`
```
$ sudo usermod -aG ubridge [nazwa_uzytkownika]
$ sudo usermod -aG libvirt [nazwa_uzytkownika]
$ sudo usermod -aG kvm [nazwa_uzytkownika]
$ sudo usermod -aG wireshark [nazwa_uzytkownika]
$ sudo usermod -aG docker [nazwa_uzytkownika]
```
* sprawdzenie statusów uruchomionych serwisów GNS3 oraz Docker
```
sudo systemctl status docker
sudo systemctl status 
```

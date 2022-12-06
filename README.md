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
$ apt-cache policy docker-ce
$ sudo apt install docker-ce
```
* sprawdzenie statusów uruchomionych serwisów GNS3 oraz Docker
```
sudo systemctl status docker
sudo systemctl status 
```

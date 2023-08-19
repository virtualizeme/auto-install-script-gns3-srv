# GNS3 Server Instalacja krok po kroku


* wygodniejszy dostęp otrzymasz z uruchomionym serwerem SSH (można go włączyć i uruchomić podczas instalacji Ubuntu Server)
* zrób update i upgrade swojej dystrybucji 
```
$ sudo apt get update
$ sudo apt get upgrade
```
### Instalacja serwera GNS3 z webGUI
* dodanie repozytorium GNS3
** po wyświetleniu informacji, czy użytkownicy inni niż root powinni mieć możliwość korzystania z wireshark i ubridge, wybierz „Tak” w obu przypadkach), wybór "Nie" będzie skutkować brakiem możliwości dodania do systemowych grup GNS'a. 
Paczka IOU musi zostać doinstalowana, wsparcie dla Dynamips jest zawarte w GNS3.
Można również doinstalować przez CLI VirtualBox lub vMware Player lub Workstation.
```
$ sudo add-apt-repository ppa:gns3/ppa
$ sudo apt update                                
$ sudo apt install gns3-server
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
* dodanie naszego użytkownika do grup usług dla serwisu GNS tj. `ubridge libvirt kvm docker`
```
$ sudo usermod -aG ubridge [nazwa_uzytkownika]
$ sudo usermod -aG libvirt [nazwa_uzytkownika]
$ sudo usermod -aG kvm [nazwa_uzytkownika]
# $ sudo usermod -aG wireshark [nazwa_uzytkownika]. ==> opcjonalnie przy instalacji z interakcja uzytkownika kiedy chcesz zeby packet capture mogli rowniez robic uzytkownicy non-root
$ sudo usermod -aG docker [nazwa_uzytkownika]
```
* sprawdzenie statusów uruchomionych serwisów GNS3 oraz Docker
```
$ sudo systemctl status docker
```
Output:
```
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-12-06 11:15:38 UTC; 22s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 8816 (dockerd)
      Tasks: 18
     Memory: 23.2M
        CPU: 375ms
     CGroup: /system.slice/docker.service
             └─8816 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```
* po instalacji GNS serwer będzie nieaktywny
```
$ sudo systemctl status gns3server.service
○ gns3server.service - GNS3 server
     Loaded: loaded (/lib/systemd/system/gns3server.service; disabled; vendor preset: enabled)
     Active: inactive (dead)
```

* uruchamiamy serwis oraz dodajemy serwis GNS i Docker do autostartu systemu (GNS weGUI uruchomi się na porcie 3080 co widać w statusie uruchomionej usługi)
```
$ sudo systemctl start gns3server.service
● gns3server.service - GNS3 server
     Loaded: loaded (/lib/systemd/system/gns3server.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-12-06 11:23:24 UTC; 5s ago
   Main PID: 9127 (gns3server)
      Tasks: 1 (limit: 77039)
     Memory: 37.5M
        CPU: 657ms
     CGroup: /system.slice/gns3server.service
             └─9127 /usr/share/gns3/gns3-server/bin/python /usr/bin/gns3server

gru 06 11:23:24 server gns3server[9127]: 2022-12-06 11:23:24 INFO run.py:243 Running with Python 3.10.6 and has PID 9127
gru 06 11:23:24 server gns3server[9127]: 2022-12-06 11:23:24 INFO run.py:79 Current locale is pl_PL.UTF-8
gru 06 11:23:25 server gns3server[9127]: 2022-12-06 11:23:25 INFO web_server.py:318 Starting server on 0.0.0.0:3080
```
* dodajemy Docker oraz GNS3 do uruchamiania wraz ze startem systemu
```
sudo systemctl enable gns3server.service
sudo systemctl enable docker
```
## Minimal Desktop enviroment (gnome-session), virtual machine manager dla QEMU/KVM.
* minimalne środowisko graficzne oparte o Gnome (przy mocniejszych parametrach serwera)
```
$ sudo apt install gnome-session gdm3
$ sudo apt install gnome-terminal
$ sudo apt install nautilus
```
* minimalne środowisko graficzne oparte o Xfce (przy slabszych parametrach serwera)
```
$ sudo apt install task-xfce-desktop
```
Podczas instalacji wybieramy `display manager` a tam  lżejsza wersje - `lightdm`
* Jeżeli paczka nie posiadałaby w sobie dodatkowych elementów typu `terminal` `files` itp. można je pobrac dzięki `apt` analogicznie jak do GNOME.
* do wygodniejszego tworzenia maszyn dla `QEMU` którę posłużą dla GNS3 jako `templates` można wykorzystac Virtual Machine Manager od RedHat
```
$ sudo apt install virt-manager
```



🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/@virtualizeMe)

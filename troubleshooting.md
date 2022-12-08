# Troubleshooting
* W tym pliku zamieszczam napotkane problemy w czasie deploymentu maszyn, obrazów dysków `*.qcow2`, ustawień sieciowych w KVM czy maszyn wirtualnych z przeznaczeniem do budowania cyber-range.
### Security Onion
1. Napotkany problem dotyczy, zmiany nazwy interfejsów sieciowych z `eth[xx]` na `ens[xx]`. W normalnie bootującym się systemie linuxy niebyłby to problem, jednak tworząc `template` kreator instalacji Security Onion zapisuje w plikach odpowiadających za konfigurację sieciową sensoru dokładne nazwy interfejsów sieciowych które widnieją podczas instalacji, natomiast `KVM` w GNS3 po zrobieniu `clone` do projektu przypisuje karty sieciowe `e1000` co w wyniku po uruchomieniu SOnion w projekcie gubi statyczna adresacje podana w kreatorze instalacji i pobiera DHCP na nowo wykryty interfejs.
- Rozwiązaniem problemu w przypadku SOnion (Centos7) jest dodanie linii `net.ifnames=0 biosdevname=0` w pliku konfiguracyjnym `GRUB bootloader`.
Plik znajduje się w `/etc/default/grub`. Linię dodajemy przy `GRUB_CMDLINE_LINUX=...` przed słowem `rhgb`.
2. Kolejnym krokiem jest sprawdzenie konfiguracji GRUB w oparciu o dodane zmiany - polecenie `grub2-mkconfig` po tym zapisujemy nowa konfiguracje GRUB `grub2-mkconfig -o /boot/grub2/grub.cfg`, po czym dokonojemy reboot systemu poprze `shutdown -r now`
- Opcjonalnie - jeżeli w folderze konfiguracji sieciowej pliki w nazwie i wewnatrz również posiadają nazwy `ens`, zmienimy to w następujący sposób:
```
$ sudo cp /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-eth0
$ sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="eth0"   <=== zmien tutaj z ens na eth0
UUID="84cad80a-0c42-4540-90c6-9209735e8ea8"
DEVICE="eth0" <=== zmien tutaj z ens na eth0
ONBOOT="yes"
```
### Wystawianie serwisów www maszyn QEMU poza fizyczny serwer UBUNTU
1. W przypadku posiadania wirtualnych maszyn które poprzez `vnc` posiadają tylko dostęp do `CLI` a GNS3 w `console type` nie daje mozliwosci wskazania na `http` lub `https`, mozemy dokonac `port forwarding` na zewnetrzny fizyczny interfejs. Z uwagi na bezpieczenstwo srodowiska w moim przypadku beda to tylko i wylacznie dostepy do kluczowych webUI `Security Onion` `Kibana webUI` `PaloAlto NGFW webUI` - forward do https i  portów 443.
Wykorzystamy do tego wszystkim znane `iptables`.
```
$ sudo /sbin/iptables -t nat -A PREROUTING -i ens160 -p tcp -d 192.168.88.212 --dport 12345 -j DNAT --to 192.168.122.15:443
```
`192.168.88.122` - adres ip na fizycznym interfejsie `ens160`, `192.168.122.15` - adres ip w wewnetrznej sieci (jakas VM podlaczona do NAT w GNS3)
Następnie stworzymy translacje adresów dzięki `masquarade`
```
$ sudo /sbin/iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE
$ sudo /sbin/iptables -t nat -A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE
```


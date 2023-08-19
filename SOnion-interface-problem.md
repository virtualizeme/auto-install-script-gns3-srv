### Security Onion - zmiana nazwy interfejsów sieciowych po utworzeniu maszyny z template
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
3. Oczywiście możemy równiez po wrzuceniu wirtualnej maszyny w projekt dokonac instalacji SOnion od poczatku na czystym dysku `*.qcow2`, gdzie kreator instalacji wykryje aktualne interfejsy jakie otrzymal od KVM i QEMU. Jednak zalecam skorzystac z templatki zeby zaoszczedzic na czasie, ktora w przypadku SOnion jest bardzo czasochlonna.


🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/virtualizeme)

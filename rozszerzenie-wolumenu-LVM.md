# Rozszerzenie LVM, po instalacji Ubuntu Server 22.0.4
* Ubuntu Server w powyższej wersji przy domyślnej instalacji polegającej na tzw. `dalej dalej dalej...` tworzy grupe oraz logiczny wolumen która
może nie zawsze wykorzystywać w pełni wymaganej przez Nas przestrzeni dyskowej, a takowa się przyda do wiekszych obrazów np. `ISO` `QCOW2` oraz
do `templates` naszych wzorcowych maszyn. GNS również będzie potrzebować przestrzeni do tworzenia `link clones` jeżeli ten sam `template` będzię 
użyty w projekcie kilkakrotnie lub w wielu projektach.
* sprawdzenie wolnej przestrzeni w naszym `root filesystem` - polecenie `df -h`
```
$ sudo df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              6.3G  1.4M  6.3G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   98G   35G   59G  37% /
tmpfs                               32G     0   32G   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
tmpfs                               32G     0   32G   0% /run/qemu
/dev/sda2                          2.0G  127M  1.7G   7% /boot
tmpfs                              6.3G  4.0K  6.3G   1% /run/user/0
tmpfs                              6.3G  4.0K  6.3G   1% /run/user/1000
```
Jak widać dostępne tylko 59GB gdzie na system przeznaczyłem 1TB. Oczywiście możesz przeznaczyć mniej lub zmienić `size` według konkretnych potrzeb 
bez dużego zapasu, który później można wykorzystać na inny wolumen `LVM`
* następnie sprawdzimy wolną przestrzeń w naszej `Volume Group` - polecenie `vgdisplay`
```
$ sudo vgdisplay 
[sudo] password for gns3: 
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <1022.00 GiB
  PE Size               4.00 MiB
  Total PE              261631
  Alloc PE / Size       25600 / 100.00 GiB
  Free  PE / Size       236031 / <922.00 GiB
  VG UUID               AJO3ag-Yx0B-mHQI-s2cY-SXEd-IsHT-mUYadM
  ```
  Tutaj widzimy ze jest `Free PE / Size` około 922GB, zatem użyjmy całej dostępnej wolnej przestrzeni dla naszego LVM
  * poleceniem `lvdisplay` zobaczymy dokładną ścieżkę podmontowanego wolumenu, żeby nie pomylić z ścieżką mappera `/dev/mapper/...`
  ```
  $ sudo lvdisplay 
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                xi643a-2UBk-aEWW-Gopt-0CQD-upan-7ahylG
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2022-12-06 18:48:59 +0000
  LV Status              available
  # open                 1
  LV Size                100.00 GiB
  Current LE             25600
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
  ```
  * poleceniem `lvextend` rozszerzymy wskazany przez nas wolumen LVM o całą wolną przestrzeń lub wskazaną ilość GB. W przykładzie wybrana jest całość.
  ```
  $ sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
  Size of logical volume ubuntu-vg/ubuntu-lv changed from 100.00 GiB (25600 extents) to <1022.00 GiB (261631 extents).
  Logical volume ubuntu-vg/ubuntu-lv successfully resized.
  ```
  * ponownie podajemy polecenie `lvdisplay` i widzimy zwiększony rozmiar `Logical Volume`
  ```
  $ sudo lvdisplay 
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                xi643a-2UBk-aEWW-Gopt-0CQD-upan-7ahylG
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2022-12-06 18:48:59 +0000
  LV Status              available
  # open                 1
  LV Size                <1022.00 GiB
  Current LE             261631
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
  ```
  * jednak zwiekszony volumen wymaga żeby wskazać dla naszyego systemu plików, że jest teraz dostępna większa przestrzeń dyskowa 
  w wolumenie z której `file system` może już swobodnie korzystać - wykonamy to poleceniem `resize2fs`
  ```
  $ sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv 
  resize2fs 1.46.5 (30-Dec-2021)
  Filesystem at /dev/mapper/ubuntu--vg-ubuntu--lv is mounted on /; on-line resizing required
  old_desc_blocks = 13, new_desc_blocks = 128
  The filesystem on /dev/mapper/ubuntu--vg-ubuntu--lv is now 267910144 (4k) blocks long.
  ```
  * na koncu podajemy ponownie komendę `df -h` w celu potwierdzenia ze nasz `/dev/mapper...` podmontowany do `/` jest powiększony i 
  procentowo `Use%` uległ zmniejszeniu
  ```
  $ df -h
  Filesystem                         Size  Used Avail Use% Mounted on
  tmpfs                              6.3G  1.4M  6.3G   1% /run
  /dev/mapper/ubuntu--vg-ubuntu--lv 1006G   35G  930G   4% /
  tmpfs                               32G     0   32G   0% /dev/shm
  tmpfs                              5.0M     0  5.0M   0% /run/lock
  tmpfs                               32G     0   32G   0% /run/qemu
  /dev/sda2                          2.0G  127M  1.7G   7% /boot
  tmpfs                              6.3G  4.0K  6.3G   1% /run/user/0
  tmpfs                              6.3G  4.0K  6.3G   1% /run/user/1000
  ```

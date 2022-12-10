# GNS3 - jako środowisko laboratoryjne lub ćwiczeniowe
## Mój projekt to GNS3 na Ubuntu Server 22.0.4 jako cyber-range dla zespolow RED-GREEN-BLUE.
#### Celem mojego projektu jest:
* przygotowanie skryptu instalacyjnego który ma się tylko raz uruchomić, i przeprowadzic pełna instalacje GNS3 Server bez interakcji użytkownika
  - instalacja dodatkowych paczek i zależnosci 
  - instalacja gns3 server (nie mylic z gns3 gui czyli aplikacja gns3)
  - instalacja wsparcia dla architektury i386 niezbędnej dla IOU
  - instalacja docker engine
  - dodanie do grup
  - automatyczne licencjonowanie IOU
  - automatyczne pobieranie z zdalnych zasobów plików obrazów QCOW2
  - automatyczne tworzenie template
* wykorzystanie graficznego webGUI GNS3 Server dla lepszego pokazania aktualnego srodowiska w trakcie ćwiczeń zespolow RGB
* możliwość deploymentu każdego systemu uperacyjnego na `hypervisor type 1 KVM` oraz `QEMU` który jest wykorzystywany przez GNS3 Server
* możliwość deploymentu urządzeń sieciowych dzięki wbudowanenmu wsparciu dla `Dynamips'
* możliwość deploymentu urządzeń sieciowych dzięki dodatkowych modułom wspierającym zwirtualizowanie architektury i386 - w tym przypadku dla IOU
* "odseparowanie" ćwiczących od prawdziwej sieci firmy organizującej ćwiczenie, poprzez wystawienie VNC, telnet, ssh lub http/https maszyn wirtualnych projektu na jeden adres zewnetrzny serwera GNS3 Server oraz konkretne porty dla kluczowych wariantów usług (np. Security Onion Kibana webUI lub Palo Alto FW)

## Spis treści

* [Instalacja GNS3 Server - krok po kroku](https://github.com/virtualizeme/gns3-as-a-cyber-range/blob/c680d1aa7f476e0468a4108c9cdc376af7c933dd/gns3server-install-steps.md)
* [Instalacja licencji IOU poprzez CLI](https://github.com/virtualizeme/gns3-as-a-cyber-range/blob/6abea34ef8006c04d572558c0407b9732db6b5a2/IOU-license-via-CLI.md)
* [Rozszerzenie wolumenu LVM](https://github.com/virtualizeme/gns3-as-a-cyber-range/blob/6abea34ef8006c04d572558c0407b9732db6b5a2/rozszerzenie-wolumenu-LVM.md)
* [Security Onion - zmiana nazw interfejsów podczas startowania GRUB](https://github.com/virtualizeme/gns3-as-a-cyber-range/blob/6abea34ef8006c04d572558c0407b9732db6b5a2/SOnion-interface-problem.md)
* [Wystawienie serwisów WWW wirtualnych maszyn z projektu - IPtables i UFW](https://github.com/virtualizeme/gns3-as-a-cyber-range/blob/6abea34ef8006c04d572558c0407b9732db6b5a2/iptables-ufw-ext-services.md)

#### Testing: 
  - automatyczne licencjonowanie IOU w skrypcie instalacyjnym
  - automatyczne pobieranie plików `QCOW2` z zewnetrzengo zasoby (serwer www http) oraz tworzenie templatki wykorztyjac `GNS3server API` w skrypcie instalacyjnym.
#### Roadmap:
  - end of 2022 - automatyczne tworzenie calych projektow razem z polaczeniami, wezlami w oparciu o scenariusze cwiczacych i wczesniej zaimportowane qcow2 i stworzone template z instalacji, oraz pierwszy stress test srodowiska przy maksymalnie trzech uruchomionych projektach kazdy po max 15 maszyn.
  - January 2023 - aktualizacja templatek, kolejny stress test srodowiska do 80-90% utylizacji zasobów, zależnie od parametrów serwera

## Support
Potrzebujesz pomocy - wsparcia w tej tematyce, email virtualize.me.polska@.gmail.com Z czasem dojdzie `Discord` lub `Slack` :)

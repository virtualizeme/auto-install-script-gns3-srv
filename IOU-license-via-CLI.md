# Instalacja licencji IOU na GNS3 Server tylko za pośrednictwem CLI 
### W moim przypadku nie chciałem specjalnie instalować GUI dla Ubuntu i lokalnie aplikacji GNS3 lub zdalnie aplikacją łączyć się do serwera, stąd wykonanie poniższej procedury poprzez CLI

* pobranie skrytpu w języku `python` który wygeneruje nam licencje dla IOU i przypisze go do naszego hostname
```
$ wget http://www.ipvanquish.com/download/CiscoIOUKeygen3f.py
```
*  otrzymany plik `iourc.txt` przenosimy do folderu domowego dla uzytkownika `gns3`, w tym przypadku zgodnie z skryptem instalacyjnym `/opt/gns3/` , jednoczenie zmieniając nazwę pliku na `.iourc`. Pamiętaj, że może to być to również użytkownik po instalacji Ubuntu Server i folder np. `/home/[username]`, wszystko możesz ustawić edytując skrypt instalacyjny GNS3 Server
```
mv iourc.txt /opt/gns3/.iourc
```
* na wszelki wypadek wkonajmy polecenie nadajace uprawnienia `executable` dla plików IOU
```
chmod +x /opt/gns3/images/IOU/*.*
```

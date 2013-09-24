---
layout:    post
title:     Upgrade Cisco via xmodem on FreeBSD
tags:      [ Cisco, xmodem, console, FreeBSD, ports, IOS, upgrade ]
permalink: /page/upgrade-cisco-xmodem-freebsd
---

Убил *Cisco*...

```text
     Diagnostic Console  - Systems Engineering

         Operation firmware version:  0.00.00   Status: invalid
         Boot firmware version:  3.20                          



         WARNING!!! Operation firmware is invalid.
         Upgrade firmware to enable switch operation.

     [U] Upgrade operation firmware (XMODEM)
     [S] System debug interface             

Enter Selection:
```

```bash
$sudo make -C /usr/ports/comms/minicom install clean
```

Запускаем:

```bash
$minicom -s
```

Далее *Serial port setup* => Жмем '*E*' (E -    Bps/Par/Bits       : 57600 8N1) => Жмем '*C*' (C:   9600) => Жмем '*F*' (F - Hardware Flow Control : No) => *Exit*

Отобразиться меню в котором нужно выбрать '*U*':

*[U] Upgrade operation firmware (XMODEM)*

Выбираем '*Yes*' для продолжения процесса загрузки:

Do you wish to continue with the download process, [Y]es or [N]o? Yes

Выбираем скорость нажатием '*9*':

*Do you wish to upgrade at [9]600 (console speed) or [5]7600? 9600*

Далее нажимаем *ctrl+a* и потом '*s*'. После чего нужно выбрать *xmodem*, и выбрать фаил прошивки нажатием '*space*'. И жмем *Enter* на '*Ok*' для загрузки файла.

После чего видим:

```text
     Diagnostic Console  - Systems Engineering                                                                                                                 
                                                                                                                                                               
         Operation firmware version:  9.00.07   Status: valid                                                                                                  
         Boot firmware version:  3.20                                                                                                                          
                                                                                                                                                               
                                                                                                                                                               
     [C] Continue with standard system start up                                                                                                                
     [U] Upgrade operation firmware (XMODEM)                                                                                                                   
     [S] System debug interface                                                                                                                                
                                                                                                                                                               
Enter Selection: 
```

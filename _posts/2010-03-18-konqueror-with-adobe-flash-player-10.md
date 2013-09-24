---
layout:    post
title:     Konqueror with Adobe Flash Player 10
tags:      [ Konqueror, Adobe, Flash, browser, FreeBSD, ports  ]
permalink: /page/konqueror-adobe-flash 
---

Надо было adobe flash в konqueror

```bash
%sudo make -C /usr/ports/www/nspluginwrapper install clean
%sudo make -C /usr/ports/www/linux-f10-flashplugin10 install clean
%sudo make -C /usr/ports/misc/konq-plugins-kde4 install clean
```

Непосредственно сама установка:

```bash
%nspluginwrapper -i /usr/local/lib/npapi/linux-f10-flashplugin/libflashplayer.so
%nspluginwrapper -l /home/zloidemon/.mozilla/plugins/npwrapper.libflashplayer.so
Original plugin: /usr/local/lib/npapi/linux-f10-flashplugin/libflashplayer.so
Wrapper version string: 1.2.2
```

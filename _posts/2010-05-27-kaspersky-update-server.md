---
layout:    post
title:     Kaspersky update server
tags:      [ Kaspersky, update, retranslator, FreeBSD, ports, Nginx]
permalink: /page/kaspersky-update-server
---

Устанавливаем порт retranslator:

```bash
$sudo make -C /usr/ports/security/retranslator install clean (Пока только PR 147116)
```

В файле **/usr/local/etc/retranslator.conf** указываем пути для хранения баз, и продукты для которых нужно получать обновления. Дополнительную информацию можно получить тут.

```ini
[path]
RetranslationPath=/path/to/kav.local/bases
TempPath=/tmp

[locale]
DateFormat=%d-%m-%Y
TimeFormat=%H:%M:%S

[updater.path]
BackUpPath=/path/to/kav.local/backup
PidFile=/var/run/kav-retranslator.pid

[updater.options]
RetranslateComponentsList=KDB, KDBI386, CORE, ARK, BSS, ADBU, ADB, AH, AH2I386, AH2X64, APU, AP, AS, BB, BB2, BLST, BLST2, KAV9EXEC, KAV8EXEC, INFO, RT, WMUF, WA, WAVI386, VLNS, EMU, PAS4, PAS, PARCTL, SSA, ASTRM, HIPS, HIPS2, KSN, QSCAN, UPDATER

Index=u0607g.xml
IndexRelativeServerPath=index
UseUpdateServerUrl=no
UseUpdateServerUrlOnly=no
UpdateServerUrl=
RegionSettings=ru
ConnectTimeout=20
KeepSilent=no
UseProxy=no
ProxyAddress=
PassiveFtp=no
PostRetranslateCmd=

[updater.report]
Append=no
ReportFileName=/var/log/retranslator.log
ReportLevel=0
```

Добавляем строку с заданием в cron для обновления каждые полчаса:

```bash
1,31 * * * * root /usr/local/bin/retranslator -q -c /usr/local/etc/retranslator.conf
```

Часть конфига для nginx:

```nginx
server {
	listen 80;
	servername kav.local;

	accesslog /var/log/webserver/kav.local_access.log;

	location / {
		root /path/to/www/kav.local/bases;
		autoindex on;
	}
}
```

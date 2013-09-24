---
layout:    post
title:     DooM 3 on FreeBSD
tags:      [ DooM3, games, ports, FreeBSD ]
permalink: /page/doom3
---

Ставим порт:

```bash
%sudo make -C /usr/ports/games/linux-doom3
```

Настраиваем **linuxulator**
Копируем с установочных диска(ов)

```bash
pak000.pk4
pak001.pk4
pak002.pk4
pak003.pk4
pak004.pk4
```

сюда **/usr/local/lib/linux-doom3/base**. Если не получается ввести свой ключик вписываем его в:

```bash
~/.doom3/base/doomkey
~/.doom3/base/xpkey
```

Выглядить должен примерно так:

```bash
AAAAAAAAAAAAAAAA
// Do not give this file to ANYONE.
// id Software and Activision will NOT ask you to send this file to them.
```
в обоих файлах.
Если нет звука, а поумолчанию его нету. Запускаем так:

```bash
%linux-doom3 +set s_driver oss
```

Я использую широкоформатный дисплей, для нормального функционирования настраиваем:
**~/.doom3/base/DoomConfig.cfg** вот эти строки:

```bash
seta r_customHeight "900"
seta r_customWidth "1440"
seta r_fullscreen "1"
seta r_mode "-1"
```

Добовляем в **/etc/hosts** (если используется пиратская версия)

``bash
127.0.0.1               idnet idnet.ua-corp.com
```

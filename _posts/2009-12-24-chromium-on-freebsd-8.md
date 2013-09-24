---
layout:    post
title:     Chromium в FreeBSD 8
tags:      [ Chromium, FreeBSD, ports, patch, diff, Git, browser ]
permalink: /page/chromium-freebsd-8
---

**English version** [chromium-english]
**Информация больше не актуальна, используйте английскую версию руководства для сборки. Мы ее регулярно дополняем и изменяем. Если есть вопросы меня можно найти в jabber.**

Устанавливаем того, чего не хватает:

```bash
%sudo make -C /usr/ports/security/nss install clean
%sudo make -C /usr/ports/x11-toolkits/gtk20 install clean
%sudo make -C /usr/ports/devel/gconf2 install clean
%sudo make -C /usr/ports/devel/libexecinfo install clean
%sudo make -C /usr/ports/devel/git config install clean #собираем с поддержкой svn
%sudo make -C /usr/ports/devel/subversion install clean
%sudo make -C /usr/ports/shells/bash install clean[/code]
```

Если у вас установлено **devel/icu** его обязательно нужно деинсталлировать! Его можно будет поставить обратно. Иначе не чего не будет компилироваться.
Перемещаем нужные файлы:

```bash
%cp /usr/local/include/execinfo.h /usr/include
```

Патчи положил в git репу [chromium-patches] тк автор удалил их с сайта... Так же он выкладывает регулярно последнии версии у себя на сайте [chromium-jaggeri]
Изменяем патчь для работы с [FreeBSD] 8:

```bash
%sed -e 's,freebsd7,freebsd8,g' 35057.patch > 35057-freebsd8.patch
```

Получаем исходные коды:

```bash
%svn co http://gclient.googlecode.com/svn/trunk/ gclient
%mkdir chrome;cd chrome
%python ../gclient/gclient/gclient.py config http://src.chromium.org/svn/trunk/src
%python ../gclient/gclient/gclient.py sync --revision src@35057
```

Патчим исходные коды:

```bash
%cd src
%git apply ../../35057-freebsd8.patch
%patch -p0 < ../../svndiffs-35057.patch
```

Компилируем:

```bash
%export GYP_GENERATORS make && python build/gyp_chromium -D'OS=freebsd' -D'use_system_libxml=1' build/all.gyp --depth ./
%gmake BUILDTYPE=Release chrome
```

Очищаем от хлама:

```bash
%mkdir chrome-bin
%cd out/Release
%find . \\( -name \\*.d -o -name obj\\* \\) -prune -o -print | cpio -dump ../../chrome-bin
```

Монтируем procfs:

```bash
%sudo mount -t procfs proc /proc
```

Запускаем:

```bash
%cd ../../chrome-bin;./chrome
```

**PS:** Не у всех работает ;). У меня к примеру получилось запустить после чистой сборки ports в jail окружении...

[FreeBSD]: http://www.freebsd.org/
[chromium-english]: http://wiki.freebsd.org/Chromium
[chromium-patches]: http://gitorious.org/zloidemon-freebsd-ports/trunk/trees/master/patches/chromium
[chromium-jaggeri]: http://chromium.jaggeri.com/

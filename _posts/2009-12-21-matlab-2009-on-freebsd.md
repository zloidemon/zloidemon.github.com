---
layout:    post
title:     MATLAB 2009 в FreeBSD
tags:      [ MATLAB, FreeBSD, Linux, linuxulator, Java, emulation ]
permalink: /page/matlab-2009
---

Установка кривая, но работает через эмуляцию GNU/Linux.

Настраиваем **linuxulator**.
Монтируем образ:

```bash
%sudo mdconfig -f Mathworks.Matlab.R2009a.UNIX.iso
%sudo mount_cd9660 /dev/md0 /cdrom
```

 Запускаем инстолятор в **окружении** linuxulator:

```bash
%/compat/linux/bin/sh /cdrom/install
```

Соответственно следуем инструкциям графического инсталлятора...

Так же есть возможно запуска в консоле, для этого запускаем:

```bash
%/compat/linux/bin/sh /cdroom/install -t
```

И аналогично графическому следуем инструкциям.
С первого раза не запустилось, ругалось вот так:

```bash
sys/java/jre/glnx86/jre/bin/java: error while loading shared libraries: libjli.so: cannot open shared object file: No such file or directory
```

Я так и не понял чей это косяк, мой или разработчиков. Но суть не в этом, главное чтоб заработало. 
Производятся действия в папке куда указан путь установки.

```bash
%cd sys/java/jre/glnx86/jre/lib/i386
%ln -s jli/libjli.so
```

После чего запускаем **matlab**, так же активируем лицензии и тд.

```bash
%/compat/linux/bin/sh matlab
```

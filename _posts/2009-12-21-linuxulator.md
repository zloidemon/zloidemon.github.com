---
layout:    post
title:     linuxulator
tags:      [ kernel, Linux, emulation, linuxulator, sysctl, ports, FreeBSD ]
permalink: /page/linuxulator
---

Я предпочитаю монолитное ядро, рассматривать модульную структуру не вижу смысла, так как про нее очень много написано.

Это нужно добавить в конфигурационный файл ядра:

```bash
options         COMPAT_LINUX
options         LINSYSFS
options         LINPROCFS
```

И собрать и установить конечно же.
Ставим интересующий вас **linux_base** из имеющихся на данный момент в древе **/usr/ports**:

```bash
linux_base-f10
linux_base-f7
linux_base-f8
linux_base-f9
linux_base-fc4
linux_base-fc6
linux_base-gentoo-stage1
linux_base-gentoo-stage3
```

Я использую который идет по умолчанию в [FreeBSD] 8:

```bash
%sudo make -C /usr/ports/emulators/linux_base-f10
```

Так же нужно добавить несколько строк в <b>/etc/fstab</b>:

```bash
linsys /compat/linux/sys linsysfs rw 0 0
linproc /compat/linux/proc linprocfs rw 0 0
```

В некоторых случаях придется изменить версию GNU/Linux ядра, для этого нужно воспользоваться **/etc/sysctl.conf**. Это актуально в старых версиях [FreeBSD].

```bash
compat.linux.osrelease=2.6.16
```

[FreeBSD]: http://www.freebsd.org/

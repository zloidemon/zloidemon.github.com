---
layout:    post
title:     SSHFs + usermount
tags:      [ SSHFs, fuse, FreeBSD, ports, devfs, sysctl ]
permalink: /page/sshfsusermount
---

Ставим порт и разрешаем монитровать пользователям:

```bash
%sudo make -C /usr/ports/sysutils/fusefs-sshfs install clean
%sudo echo 'vfs.usermount=\"1\"'>>/etc/sysctl.conf
%sudo pw groupmod operator -m username
%sudo echo 'fusefs_enable=\"YES\"'>>/etc/rc.conf
```

Добавляем это в /etc/devfs.conf

```bash
ruleset 10
rule    fuse*   0666
```

Рестартим сервисы:

```bash
%sudo /usr/local/etc/rc.d/fusefs restart
%sudo /etc/rc.d/devfs restart
```

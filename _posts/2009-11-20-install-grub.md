---
layout:    post
title:     Install grub
tags:      [ Grub, boot, FreeBSD ]
permalink: /page/ustanovka-grub
---

```bash
%sudo sysctl kern.geom.debugflags=16
```
Ставим этот порт:
```bash
%sudo make -C /usr/ports/sysutils/grub install clean
```

```bash
/dev/ad0s1a /
/dev/ad0s2f /home
/dev/ad0s1f /tmp
/dev/ad0s2d /usr
/dev/ad0s2e /usr/local
/dev/ad0s1d /var
/dev/ad0s1e /var/tmp
```

```bash
%sudo grub-install /dev/ad0
%cat /boot/grub/menu.lst
color light-gray/blue black/light-gray
default 0
timeout 30

title FreeBSD
root (hd0,0,a)
kernel /boot/loader
boot

title safe
root (hd0,0,a)
kernel /boot/loader -s
boot

title reboot
reboot

title shutdown
halt
```

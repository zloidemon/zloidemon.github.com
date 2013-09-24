---
layout:    post
title:     Grub + USB flash
tags:      [ Grub, USB, boot, FreeBSD ]
permalink: /page/grubusb-flash
---

```bash
%sudo make -C/usr/ports/sysutils/grub install clean && rehash
%sudo mount_msdosfs /dev/da0s1 /mnt/
%sudo mkdir -p /mnt/boot/grub
%sudo cp /usr/local/share/grub/i386-freebsd/* /mnt/boot/grub/
%sudo umount /mnt/
%sudo grub
grub> device (hd0) /dev/da0


grub> root (hd0,0)
Filesystem type is fat, partition type 0xb

grub> setup (hd0)
Checking if "/boot/grub/stage1" exists… yes
Checking if "/boot/grub/stage2" exists… yes
Checking if "/boot/grub/fat_stage1_5" exists… yes
Running "embed /boot/grub/fat_stage1_5 (hd0)"… 17 sectors are embedded.
succeeded
Running "install /boot/grub/stage1 (hd0) (hd0)1+17 p (hd0,0)/boot/grub/stage2 /boot/grub/menu.lst"… succeeded
Done.

grub> quit
```

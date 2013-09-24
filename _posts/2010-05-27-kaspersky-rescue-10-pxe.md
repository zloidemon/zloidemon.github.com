---
layout:    post
title:     Kaspersky Rescue 10 PXE
tags:      [ PXE, Kaspersky, rescue, boot, antivirus ]
permalink: /page/kaspersky-rescue-10-pxe
---

**Depends on squashfs-tools > 3!**

```bash
# Downloading files....
$wget -c http://devbuilds.kaspersky-labs.com/devbuilds/RescueDisk10/kavrescue10.iso
$wget -c http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/raw/master/patches/PXE/patch-PXEkavrescue2010.iso.patch
# Installing needed stuff
$sudo make -C /usr/ports/archivers/gcpio install clean
$sudo make -C /usr/ports/sysutils/squashfs-tools install clean
# Building image
$mdconfig -f kavrescue10.iso
$mountcd9660 /dev/md0 /cdrom
$cp -v /cdrom/boot/rescue ./
$mkdir image && cd image
$zcat /cdrom/boot/rescue.igz |gcpio -id
$patch -p0 < ../patch-PXEkavrescue2010.iso.patch
$mkdir cdrom && cp -R /cdrom/rescue cdrom/
$mksquashfs cdrom cdrom.squashfs && rm -fr cdrom
$sudo cp /cdrom/image.squashfs ./
$sudo chmod 644 image.squashfs
$find . -print | gcpio -o -H newc > ../rescue.igz && ../ && rm -fr image/
```

Example config:

```ini
label KAV10 rescue RUS
kernel data/antivir/kav10/rescue
append initrd=data/antivir/kav10/rescue.igz root=/dev/ram0 cdroot=1 kavlang=ru loop=image.squashfs looptype=squashfs realroot=/

label KAV10 rescue ENG
kernel data/antivir/kav10/rescue
append initrd=data/antivir/kav10/rescue.igz root=/dav/ram0 cdroot=1 kavlang=en loop=image.squashfs looptype=squashfs realroot=/

label KAV10 rescue text mode
kernel data/antivir/kav10/rescue
append initrd=data/antivir/kav10/rescue.igz root=/dev/ram0 cdroot=1 kavlang=en loop=image.squashfs looptype=squashfs real_root=/ nox kavshell
```

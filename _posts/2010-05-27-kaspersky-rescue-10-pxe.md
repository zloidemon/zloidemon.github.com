---
layout:    post
title:     Kaspersky Rescue 10 PXE
tags:      [ PXE, Kaspersky, rescue, boot, antivirus ]
permalink: /page/kaspersky-rescue-10-pxe
---

**Depends on squashfs-tools > 3!**

Patch patch-PXE-kav_rescue_10.iso.patch

```diff
{% asset kaspersky/patch-PXE-kav_rescue_10.iso.patch %}
```

Build instructions:

```bash
$mdconfig -f kav_rescue_10.iso
$mountcd_9660 /dev/md0 /cdrom
$cp -v /cdrom/boot/rescue .
$mkdir image && cd image
$lzcat -S lz /cdrom/boot/rescue.igz | cpio -id
$patch -p0<../../patch-PXE-kav_rescue_10.iso.patch
$mkdir cdrom && cp -R /cdrom/rescue cdrom/
$mksquashfs cdrom image.squashfs && rm -fr cdrom
$find . -print | cpio -o -H newc | lzma -c > /usr/local/tftp/rescue.igz && cd ../ && rm -fr image/
```
Example config pxe:

```ini
{% asset kaspersky/pxeboot_kav_rescue_10.cfg %}
```

Files: [kernel][1] and [initrd][2].

*DEPRECATED*

Patch patch-PXE_kav_rescue_2010.iso.patch

```diff
{% asset kaspersky/patch-PXE_kav_rescue_2010.iso.patch %}
```

Build instructions:

```bash
# Downloading files....
$wget -c http://devbuilds.kaspersky-labs.com/devbuilds/RescueDisk10/kavrescue10.iso
# Installing needed stuff
$sudo make -C /usr/ports/archivers/gcpio install clean
$sudo make -C /usr/ports/sysutils/squashfs-tools install clean
# Building image
$mdconfig -f kavrescue10.iso
$mountcd_9660 /dev/md0 /cdrom
$cp -v /cdrom/boot/rescue ./
$mkdir image && cd image
$zcat /cdrom/boot/rescue.igz |gcpio -id
$patch -p0 < ../patch-PXE_kav_rescue_2010.iso.patch
$mkdir cdrom && cp -R /cdrom/rescue cdrom/
$mksquashfs cdrom cdrom.squashfs && rm -fr cdrom
$sudo cp /cdrom/image.squashfs ./
$sudo chmod 644 image.squashfs
$find . -print | gcpio -o -H newc > ../rescue.igz && cd ../ && rm -fr image/
```

Example config pxe:

```ini
{% asset kaspersky/pxeboot_kavrescue10.cfg %}
```

[1]: http://storage.zlonet.ru/kav/20140106/rescue
[2]: http://storage.zlonet.ru/kav/20140106/rescue.igz


---
layout:    post
title:     Kaspersky Rescue PXE
tags:      [ boot, kernel, FreeBSD, PXE, Kaspersky, rescue, antivirus ]
permalink: /page/kaspersky-rescue-pxe
---

```bash
# Downloading files....
zloidemon$ wget -c http://devbuilds.kaspersky-labs.com/devbuilds/RescueDisk/kavrescue2008.iso
zloidemon$ wget -c http://data2.kaspersky-labs.com:8080/updater/updaterforwindowsv.3.2.0.2.zip
# Updating bases
zloidemon$ mkdir tmp && cd tmp
zloidemon$ unzip ../updaterforwindowsv.3.2.0.2.zip
zloidemon$ wget -c http://kegel.com/wine/winetricks
zloidemon$ chmod +x winetricks
zloidemon$ ./winetricks vcrun2005
zloidemon$ mkdir -p Temp/temporaryFolder/bases/av/kdb/i386
zloidemon$ mkdir iso
zloidemon$ sudo mount -o loop ../kavrescue2008.iso iso/
zloidemon$ cp iso/bases/. Temp/temporaryFolder/bases/av/kdb/i386/
zloidemon$ wget -c http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/raw/master/patches/PXE/patchssstorage.ini
zloidemon$ patch -p0 < patchssstorage.ini
# My patch from http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/master/patches/PXE/patchssstorage.ini
zloidemon$ wine Updater.exe -u -o ssstorage.ini -c
zloidemon$ mkdir new && cp -R iso/bases new/
zloidemon$ cp Updates/bases/av/kdb/i386/*.* new/bases/
zloidemon$ cp Updates/bases/av/kdb/i386/kdb-i386-0607g.xml new/bases/kdb-0607g.xml
zloidemon$ cp Updates/bases/av/kdb/i386/kdb.stt new/bases/Stat/
zloidemon$ cp Updates/index/u0607g.xml new/bases/Stat/
zloidemon$ mksquashfs new bases.squashfs
# Make image for PXE boot
zloidemon$ wget -c http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/raw/master/patches/PXE/patch-PXEkavrescue2008.iso.patch
zloidemon$ mkdir pxe && cd pxe
zloidemon$ zcat ../iso/isolinux/rescue.igz |cpio -id
zloidemon$ patch -p0 <../patch-PXEkavrescue2008.iso.patch
# My patch from http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/master/patches/PXE/patch-PXEkavrescue2008.iso.patch
# This is patch based on Gentoo PXE: http://www.thegibson.org/blog/archives/13
zloidemon$ sudo cp ../iso/image.squashfs ./ && sudo chmod 644 image.squashfs
zloidemon$ cp ../bases.squashfs ./
zloidemon$ find . -print | cpio -o -H newc > ../rescue.igz
```

Example config:

```ini
label Kaspersky Rescue
kernel data/antivir/kav/rescue
append initrd=data/antivir/kav/rescue.igz root=/dev/ram0 cdroot=1 loop=image.squashfs looptype=squashfs real_root=/
```

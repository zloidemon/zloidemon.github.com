---
layout:    post
title:     Kaspersky Rescue 10 PXE
tags:      [ PXE, Kaspersky, rescue, boot, antivirus ]
permalink: /page/kaspersky-rescue-10-pxe
---

**Depends on squashfs-tools > 3!**

Patch patch-PXE-kav_rescue_10.iso.patch

```diff
--- sbin/dmsquash-live-root.orig	2014-01-05 21:26:33.581580759 +0400
+++ sbin/dmsquash-live-root	2014-01-06 21:42:30.159646123 +0400
@@ -46,9 +46,7 @@ fi
 
 # determine filesystem type for a filesystem image
 det_img_fs() {
-    local _img="$1" _loop=$(losetup -f) _fs
-    losetup $_loop $_img; _fs=$(det_fs $_loop); losetup -d $_loop
-    echo $_fs
+    echo squashfs
 }
 
 for arg in $CMDLINE; do case $arg in ro|rw) liverw=$arg ;; esac; done
@@ -62,7 +60,6 @@ if [ -f $livedev ]; then
         auto) die "cannot mount live image (unknown filesystem type)" ;;
         *) FSIMG=$livedev ;;
     esac
-else
     mount -n -t $fstype -o ${liverw:-ro} $livedev /run/initramfs/live
     if [ "$?" != "0" ]; then
         die "Failed to mount block device of live image"
--- init.orig	2014-01-05 21:26:33.571246205 +0400
+++ init	2014-01-06 19:55:26.324595021 +0400
@@ -288,7 +288,7 @@ unset main_loop
 unset RDRETRY
 
 if  ! ismounted "/run/initramfs/live"; then
-    CDROM_DEVICES="/dev/sr*"
+    CDROM_DEVICES="/image.squashfs"
     for i in $CDROM_DEVICES
     do
         /sbin/dmsquash-live-root $i
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
label kav
kernel /rescue
append initrd=/rescue.igz root=live rootfstype=auto vga=791 init=/init kav_lang=ru udev liveimg doscsi nomodeset

label kav_text
kernel /rescue
append initrd=/rescue.igz root=live rootfstype=auto vga=791 init=/init kav_lang=ru udev liveimg nox kavshell noresume doscsi nomodeset
```

Files: [kernel][1] and [initrd][2].

*DEPRECATED*

Patch patch-PXE_kav_rescue_2010.iso.patch

```diff
--- init.orig	2010-05-24 21:40:35.000000000 +0800
+++ init	2010-05-25 16:07:38.000000000 +0800
@@ -399,7 +399,7 @@ fi
 
 # Determine root device
 good_msg 'Determining root device...'
-while true
+while false
 do
 	while [ "${got_good_root}" != '1' ]
 	do
@@ -462,6 +462,8 @@ do
 		fi
 	done
 
+REAL_ROOT=/image.squashfs
+REAL_ROOT_TYPE=squashfs
 
 	if [ "${CDROOT}" = 1 -a "${got_good_root}" = '1' -a "${REAL_ROOT}" != "/dev/nfs" ]
 	then
@@ -521,7 +523,6 @@ then
 	[ -z "${LOOP}" ] && find_loop
 	[ -z "${LOOPTYPE}" ] && find_looptype
 
-	cache_cd_contents
 
 	# If encrypted, find key and mount, otherwise mount as usual
 	if [ -n "${CRYPT_ROOT}" ]
@@ -557,7 +558,8 @@ then
 		elif [ "${LOOPTYPE}" = 'squashfs' ]
 		then
 			good_msg 'Mounting squashfs filesystem'
-			mount -t squashfs -o loop,ro "${NEW_ROOT}/mnt/cdrom/${LOOPEXT}${LOOP}" "${NEW_ROOT}/mnt/livecd"
+			mount -t squashfs -o loop,ro /${LOOP} ${NEW_ROOT}/mnt/livecd
+			mount -t squashfs -o loop,rw /cdrom.squashfs ${NEW_ROOT}/mnt/cdrom
 			test_success 'Mount filesystem'
 			FS_LOCATION='mnt/livecd'
 		elif [ "${LOOPTYPE}" = 'gcloop' ]
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

[1]: http://storage.zlonet.ru/kav/20140106/rescue
[2]: http://storage.zlonet.ru/kav/20140106/rescue.igz


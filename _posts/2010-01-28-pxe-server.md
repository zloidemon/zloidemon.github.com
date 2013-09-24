---
layout:    post
title:     PXE server
tags:      [ TFTP, PXE, syslinux, gPXE, DHCP, ports, FreeBSD ]
permalink: /page/pxe-server
---

Ставим нужный софт:

```bash
$sudo make -C /usr/ports/ftp/tftp-hpa install clean
$sudo mkdir -p /var/data/tftp
$sudo pkg_add -ri syslinux
$sudo cp /usr/local/share/syslinux/gpxelinux.0 /var/data/tftp
$sudo mkdir /var/data/tftp/syslinux
$sudo cp -v /usr/local/share/syslinux/*.c32 /var/data/tftp/syslinux/
$sudo mkdir /var/data/tftp/pxelinux.cfg
```

Некоторые полезные tools:

```bash
$sudo mkdir /var/data/tftp/tools
$sudo cd /var/data/tftp/tools
$sudo fetch http://www.memtest.org/download/2.01/memtest86+-2.01.bin.gz
$sudo gunzip memtest86+-2.01.bin.gz
$sudo fetch http://www.hdt-project.org/raw-attachment/wiki/hdt-0.3.5/hdt_0_3_5.c32
# Parted Magic
$sudo fetch http://cdnetworks-kr-1.dl.sourceforge.net/project/partedmagic/partedmagic/Parted%20Magic%204.8/pmagic-pxe-4.8.zip
$sudo tar zxf pmagic-pxe-4.8.zip
$sudo mv pmagic-pxe-4.8/pmagic ./
# Norton Recovery Tool 
$sudo mkdir symantec && cd symantec
$sudo fetch ftp://ftp.symantec.com/public/english_us_canada/recovery/2009/NSWRECOVERY.iso
$sudo fetch ftp://ftp.symantec.com/public/english_us_canada/recovery/2009/NAV/recovery_nav_x86.iso
$sudo fetch ftp://ftp.symantec.com/public/english_us_canada/recovery/2009/NIS/recovery_nis_x86.iso
$cd ../
# Скачать Hirens BootCD можно здесь http://www.hirensbootcd.net
$sudo tar xzf Hirens.BootCD.10.1.zip
$sudo rm BootCD.txt Burn* DefaultKeyboardPatch.zip changes-10.0-10.1.txt HBCDCustomize.exe
$sudo mv Hirens.BootCD.10.1.iso hirens_bootcd.10.1.iso
```

Собственно FreeBSD:

```bash
$sudo mkdir ../freebsd && cd ../freebsd
$sudo fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/ISO-IMAGES/8.0/8.0-RELEASE-i386-bootonly.iso
$sudo dd if=/dev/zero of=8.0-RELEASE-i386-bootonly.img bs=1k count=45000
$sudo mdconfig -f 8.0-RELEASE-i386-bootonly.img -u 0
$sudo bsdlabel -w -B md0 auto
$sudo newfs -m 0 md0a
$sudo mkdir /tmp/img
$sudo mount /dev/md0a /tmp/img
$sudo mdconfig -f 8.0-RELEASE-i386-bootonly.iso -u 1
$sudo mount_cd9660 /dev/md1 /cdrom/
$sudo cp -rv /cdrom/* /tmp/img/
$sudo umount /cdrom/ /tmp/img/ && mdconfig -d -u 0 && mdconfig -d -u 1
```

Для amd64 все так же только размеры чуток другой:

```bash
$sudo fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/ISO-IMAGES/8.0/8.0-RELEASE-amd64-bootonly.iso
%sudo dd if=/dev/zero of=8.0-RELEASE-amd64-bootonly.img bs=1k count=48000
```

Некоторые GNU/Linux LiveCD:

```bash
%cd /var/data/tftp/data&& sudo mkdir linux&&cd linux
%sudo fetch http://distro.ibiblio.org/pub/linux/distributions/tinycorelinux/2.x/release/tinycore-current.iso
%sudo mdconfig -f tinycore-current.iso -u 0
%sudo mount_cd9660 /dev/md0 /cdrom/
%sudo mkdir tinycore
%sudo cp /cdrom/boot/tinycore.gz tinycore/
%sudo cp /cdrom/boot/bzImage tinycore/
%sudo umount /cdrom/ && mdconfig -d -u 0
%sudo fetch http://cdnetworks-kr-1.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/1.3.5/systemrescuecd-x86-1.3.5.iso
%sudo mdconfig -f systemrescuecd-x86-1.3.5.iso -u 0
%sudo mount_cd9660 /dev/md0 /cdrom/
%sudo mkdir systemrescuecd
%sudo cp /cdrom/sysrcd.* systemrescuecd/
%sudo cp /cdrom/isolinux/rescue* systemrescuecd/
%sudo cp /cdrom/isolinux/altker* systemrescuecd/
%sudo cp /cdrom/isolinux/initram.igz systemrescuecd/
%sudo cp /cdrom/bootdisk/* ../tools/
%sudo cp -R /cdrom/ntpasswd ../tools/
%sudo umount /cdrom/ && mdconfig -d -u 0
```

Антивирусы:

```bash
%cd ../ && sudo mkdir -p antivir/drweb
%sudo fetch ftp://ftp.drweb.com/pub/drweb/livecd/minDrWebLiveCD-5.0.1.iso
%sudo mdconfig -f minDrWebLiveCD-5.0.1.iso -u 0
%sudo mount_cd9660 /dev/md0 /cdrom/
%sudo cp -v /cdrom/boot/{initrd,vmlinuz} antivir/drweb/
%sudo chmod 644 data/antivir/drweb/initrd
%sudo cp cp -R /cdrom/boot/module antivir/drweb/
%sudo chmod 644 data/antivir/drweb/module/*

%sudo fetch http://devbuilds.kaspersky-labs.com/devbuilds/RescueDisk/kav_rescue_2008.iso
%sudo mdconfig -f kav_rescue_2008.iso -u 0
%sudo mount_cd9660 /dev/md0 /cdrom/
%sudo mkdir antivir/kav
%sudo cp /cdrom/isolinux/rescue* antivir/kav/
%sudo cp /cdrom/image.squashfs antivir/kav/
%sudo fetch ftp://anti-virus.by/pub/vbarescue.iso
%sudo mdconfig -f vbarescue.iso -u 0
%sudo mount_cd9660 /dev/md0 /cdrom
```

Добовляем строки в /etc/rc.conf :

```bash
tftpd_enable="YES"
tftpd_datadir="/var/data/tftp"
tftpd_flags="--ipv4 -s"
```

Правим /usr/local/etc/dhcpd.conf :

```bash
subnet 192.168.3.0 netmask 255.255.255.0 {
        range 192.168.3.20 192.168.3.255;
        option routers 192.168.3.100;
        filename "gpxelinux.0";
        }
$sudo /usr/local/etc/rc.d/isc-dhcpd restart
$sudo /etc/rc.d/inetd restart
```

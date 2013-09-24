---
layout:    post
title:     The JunOS installation script
tags:      [ JunOS, Juniper, FreeBSD, shell, script ]
permalink: /page/the-junos-installation-script
---

I don't like installing manually... So I've written a script for it. This is an autoamtic installation script for the JunOS olive for which you need to be using a version of [FreeBSD] < 8.  [FreeBSD] 8 is not supported.

```bash
#!/bin/sh
FILE='jinstall-10.4R1.9-domestic-signed.tgz'
HASH=649006003c9773859882411246405a39
UNTAR='tar zxf'
TAR='tar zcf'
WORK=tmp

work (){
	if [ -d $WORK ]; then
		rm -fr $WORK
	fi
	mkdir -p $WORK
	cd $WORK
}

dwork (){
	cd ../;rm -fr $WORK
}
if [ `sysctl kern.osreldate|awk '{print $2}'` -le 703000 ]; then
	if [ `md5 $FILE | awk '{print $4}'` = $HASH ]; then
			work
			$UNTAR ../$FILE
			work
			$UNTAR `echo ../$FILE|sed -e 's|-signed||g'`
			work
			$UNTAR ../pkgtools.tgz
			cp -v /usr/bin/true bin/checkpic
			$TAR ../pkgtools.tgz *
			dwork
			$TAR ../../`echo $FILE|sed -e 's|signed|olive|g'` *
			dwork;dwor
			pkg_add -f `echo $FILE|sed -e 's|signed|olive|g'`
			echo console=\"vidconsole\">>/boot/loader.conf
			reboot
	else
		exit
	fi
else
	exit
fi
```

[FreeBSD]: http://www.freebsd.org/

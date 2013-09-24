---
layout:    post
title:     Флешка и hal
tags:      [ USB, HAL, sysctl, FreeBSD ]
permalink: /page/fleha-i-hal
---

```bash
%sudo echo "vfs.usermount=1" >> /etc/sysctl.conf
%diff -up PolicyKit.conf.dist PolicyKit.conf
```
```diff
– PolicyKit.conf.dist 2009-05-11 13:24:47.027109231 +0800
+++ PolicyKit.conf 2009-05-14 16:53:17.171406382 +0800
@@ -10,4 +10,10 @@
<return result="yes" />
</match>
<define_admin_auth group="wheel" />
+ <match action="org.freedesktop.hal.storage.mount-removable">
+ <return result="yes" />
+ </match>
+ <match action="org.freedesktop.hal.storage.mount-fixed">
+ <return result="yes" />
+ </match>
</config>
```

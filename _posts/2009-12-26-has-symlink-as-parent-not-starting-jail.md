---
layout:    post
title:     has symlink as parent - not starting jail
tags:      [ jail, FreeBSD, symlink, error ]
permalink: /page/has-symlink-as-parent-not-starting-jail
---

Возникла проблема при запуске **jail**:

```bash
server# /etc/rc.d/jail start www
Configuring jails:.
Starting jails:/etc/rc.d/jail: WARNING: /home/jails/www/dev has symlink as parent - not starting jail www
```

Эта проблема возникает за того что указывается не полный путь, те используеся
**symlink** /home в ROOT.
Решается эта проблема сменой **/home/jails/www** на **/usr/home/jails/www** в rc.conf:

```bash
jail_www_rootdir="/usr/home/jails/www"
```

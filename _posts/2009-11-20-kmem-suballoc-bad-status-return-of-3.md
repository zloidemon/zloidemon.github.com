---
layout:    post
title:     'kmem_suballoc: bad status return of 3'
tags:      [ kernel, panic, boot, FreeBSD ]
permalink: /page/kmem_suballoc-bad-status-return-of-3
---

```bash
panic: kmem_suballoc: bad status return of 3
```

Возникает в ядре, при выставленных **kmem** в **loader.conf**. Волшебная строчка для конфига ядра( **x86** платформы):

```bash
options KVA_PAGES=512
```

---
layout:    post
title:     Конвертирование тегов в mp3 в UTF-8
tags:      [ converting, UTF-8, CP1251, mp3, mutagen, iconv ]
permalink: /page/konvertirovanie-tegov-v-utf-8
---

**Mutagen** как ни когда подходит для этого черного дела:

```bash
%mid3iconv -d -eCP1251 --remove-v1 *.mp3
```
или

```bash
%find /path/to/mp3/files/ -name '*.mp3' -exec mid3iconv -d -eCP1251 --remove-v1 "{}" \;
```

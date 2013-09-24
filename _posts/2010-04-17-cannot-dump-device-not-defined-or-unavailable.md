---
layout:    post
title:     Cannot dump. Device not defined or unavailable.
tags:      [ coredump, panic, kernel, FreeBSD ]
permalink: /page/cannot-dump-device-not-defined-or-unavailable
---

Сегодня при возникновении **Kernel panic** обнаружил что не используется swap.

```bash
Cannot dump. Device not defined or unavailable.
```

Для решения этой проблемы нужно было добавить всего лишь одну строку в **/etc/rc.conf**:

```bash
dumpdev="AUTO"
```

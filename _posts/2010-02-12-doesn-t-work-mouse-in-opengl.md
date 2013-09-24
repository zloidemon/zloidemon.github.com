---
layout:    post
title:     Не работает мышка в OpenGL
tags:      [ OpenGL, X, hardware, mouse, FreeBSD, ports, games, q3 ]
permalink: /page/ne-rabotaet-myshka-v-opengl
---

После обновления всплыла новая проблема, перестала работать мышь во всех приложения использующих **OpenGL**. Заметил это лишь после запуска q3...
Решил проблему пересборкой:

```bash
$portmaster libXxf86dga xf86dga xf86dgaproto
```

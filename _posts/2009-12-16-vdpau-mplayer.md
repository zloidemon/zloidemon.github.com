---
layout:    post
title:     VDPAU + MPlayer
tags:      [ MPlayer, VDPAU, ports, NVidia, kernel, FreeBSD ]
permalink: /page/vdpau-mplayer
---

Копируем нужные файлы:

```bash
%sudo mkdir /usr/local/include/vdpau
%sudo cp -R /usr/local/share/doc/NVIDIA_GLX-1.0/vdpau* /usr/local/include/vdpau
```

Скачиваем mplayer+vdpau:

```bash
%svn co svn://svn.mplayerhq.hu/mplayer/trunk mplayer
```

Обновляем драйвер:

```bash
%sudo portmaster nvidia-driver
```

Установка:

```bash
%cd mplayer
%./configure --disable-x264-lavc --disable-x264 --enable-vdpau && gmake
```

Запуск видео:

```bash
%cd ./mplayer-vdpau
%./mplayer -vo vdpau -vc ffmpeg12vdpau *.mpg
%./mplayer -vo vdpau -vc ffh264vdpau *.h264
%./mplayer -vo vdpau -vc ffh264vdpau *.ts
%./mplayer -vo vdpau -vc ffwmv3vdpau *.wmv
%./mplayer -vo vdpau -vc ffvc1vdpau *.wmv
```

Прирост производительности у меня составил 10-60% в зависимости от видео.

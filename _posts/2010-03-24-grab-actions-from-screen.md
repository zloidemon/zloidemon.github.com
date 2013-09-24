---
layout:    post
title:     Захват экрана в видео
tags:      [ screencast, x11grab, FreeBSD, ports, shell, video ]
permalink: /page/zahvat-ekrana-v-video
---

Скрипт для захвата экрана в видео. На мой взгляд лучший вариант из всего что я видел.
Собираем порт с активной опцией **X11GRAB**:

```bash
$sudo make -C /usr/ports/multimedia/ffmpeg/ config install clean
```

```bash
#!/bin/sh

name="$(date +%F-%T)"
# Desktop
#ffmpeg -f oss -i /dev/dsp -acodec ac3 -ab 192k -f x11grab -s 1440x900 -r 30 -isync -i :0.0 -sameq -y -vcodec mpeg4 ~/desktop.${name}.mp4
#ffmpeg -f oss -i /dev/dsp -acodec ac3 -ab 128k -f x11grab -s 1440x900 -r 30 -g 120 -isync -i :0.0 -s 800x500 -sameq -y ~/desktop.${name}.mpg
#only video
ffmpeg -f x11grab -s 1440x900 -r 30 -g 120 -isync -i :0.0 -s 800x500 -sameq -y ~/desktop.${name}.mpeg
#video and sound
#ffmpeg -f oss -i /dev/dsp -acodec ac3 -ab 128k -f x11grab -s 1440x900 -r 30 -g 120 -isync -i :0.0 -s 800x500 -sameq -y ~/desktop.${name}.mpeg
# Webcam (not work - error open /dev/video0)
#ffmpeg -f oss -i /dev/dsp -f video4linux2 -i /dev/video0 ~/desktop.${name}.mp4
```

Спасибо **fidaj** за скрипт :)

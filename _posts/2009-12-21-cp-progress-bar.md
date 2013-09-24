---
layout:    post
title:     cp (progress bar)
tags:      [ copy, progress, rsync, ports, FreeBSD, perfomance ]
permalink: /page/cp-progress-bar
---

Захотелось наблюдать прогресс копирования файлов, те нужна была замена стандартной *cp*.
Вот что получилось:

```bash
dir/file.bin
        1625 100%    9.50kB/s    0:00:00 (xfer#8661, to-check=3/9625)
```

Для замены выбрал rsync:

```bash
%sudo -C /usr/ports/net/rsync install clean
```

Для копирования пользуемся:

```bash
rsync -rv --progress file_in file_out
```

Небольшое сравнение, что заставило отказаться от этой затеи.

Копирование одного файла размером **1,7G**:

```bash
результат rsync: 13,82s user 11,99s system 23% cpu 1:47,75 total
результат cp:    0,00s user 5,78s system 4% cpu 1:58,71 total
```

Много мелких файлов:

```bash
результат rsync: 1,59s user 3,48s system 10% cpu 48,672 total
результат cp:    0,04s user 1,33s system 17% cpu 7,915 total
```

Вывод: не нужно.

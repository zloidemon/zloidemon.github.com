---
layout:    post
title:     ISPConfig не видет MySQL
tags:      [ ISPConfig, MySQL, jail, sysctl ]
permalink: /page/ispconfig-ne-videt-mysql
---

```bash
Please enter your MySQL server:localhost
The MySQL server you specified cannot be reached!
Please enter your MySQL server:192.168.0.1
The MySQL server you specified cannot be reached!
Please enter your MySQL server:name.server
The MySQL server you specified cannot be reached!
Please enter your MySQL server:127.0.0.1
The MySQL server you specified cannot be reached!
```

Запуск производился в **jail**… путем поиска проблемы в коде было найдено, что проверяется сервер пигами.

```bash
%sudo sysctl security.jail.allow_raw_sockets=1
security.jail.allow_raw_sockets: 0 -> 1
```

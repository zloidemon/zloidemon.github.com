---
layout:    post
title:     Ignoring query to other database
tags:      [ MySQL, man, SQL ]
permalink: /page/ignoring-query-to-other-database
---

**MySQL** выдае ошибку при любых обращениях:

```sql
mysql> show DATABASES;
Ignoring query to other database
```

решение проблемы(из мана):

```bash
--verbose, -v Verbose mode. Produce more output about what the program does.
This option can be given multiple times to produce more and more output.
(For example, -v -v -v produces table output format even in batch mode.)
```

Пример подключения:
```bash
%mysql -v -u root -p
```

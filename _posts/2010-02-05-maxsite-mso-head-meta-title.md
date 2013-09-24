---
layout:    post
title:     "MaxSite: mso_head_meta('title')"
tags:      [ MaxSite, PHP, error ]
permalink: /page/maxsite-mso_head_metatitle
---

После обновления веб сервера, перестал корректно работать MaxSite CMS. Проблема заключалась в в том, что PHP обрабатывал только

```php
<?php
```

но не работал

```php
<?
```

Решение подсказал vsjcf. Нужно исправить одну строку в */usr/local/etc/php.ini*

```ini
short_open_tag = On
```

**UDP:** поправка от [ixti].

```bash
$echo 'php_flag short_open_tag on' >> .htaccess
```

[ixti]: http://ixti.ru/

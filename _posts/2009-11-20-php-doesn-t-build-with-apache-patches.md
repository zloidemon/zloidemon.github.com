---
layout:    post
title:     PHP ругается на Apache
tags:      [ PHP, Apache, error, build, ports, FreeBSD, patch ]
permalink: /page/php-rugaetsja-na-indusa
---

```php
/usr/local/include/apache22/http_log.h:350: error: expected ')' before 'void'
In file included from /usr/ports/lang/php5/work/php-5.2.11/sapi/apache/php_apache_http.h:63,
                 from /usr/ports/lang/php5/work/php-5.2.11/sapi/apache/sapi_apache.c:24:
/usr/local/include/apache22/util_script.h:90: error: expected declaration specifiers or '...' before 'apr_file_t'
/usr/local/include/apache22/util_script.h:104: error: expected declaration specifiers or '...' before 'apr_bucket_brigade'
/usr/ports/lang/php5/work/php-5.2.11/sapi/apache/sapi_apache.c: In function 'apache_php_module_main':
/usr/ports/lang/php5/work/php-5.2.11/sapi/apache/sapi_apache.c:44: error: 'NOT_FOUND' undeclared (first use in this function)
/usr/ports/lang/php5/work/php-5.2.11/sapi/apache/sapi_apache.c:44: error: (Each undeclared identifier is reported only once
/usr/ports/lang/php5/work/php-5.2.11/sapi/apache/sapi_apache.c:44: error: for each function it appears in.)
*** Error code 1
```

Проблема была в версии **Apache**, лечиться пересборкой без *спец патчей*.

---
layout:    post
title:     Проблемы с memcache после обыновления PHP
tags:      [ PHP, coredump, memcached, error]
permalink: /page/problemy-s-memcache-posle-obynovlenija-php
---

```php
Fatal error: Uncaught exception 'Zend_Cache_Exception' with message
'The memcache extension must be loaded for using this backend !' in /site/classes/lib/external/DklabCache/Zend/Cache.php:141
Stack trace:
#0 /site/classes/lib/external/DklabCache/Zend/Cache/Backend/Memcached.php(97): Zend_Cache::throwException('The memcache ex...')
#1 /site/classes/modules/sys_cache/Cache.class.php(76): Zend_Cache_Backend_Memcached->__construct(Array)
#2 /site/classes/engine/Engine.class.php(68): LsCache->Init()
#3 /site/classes/engine/Router.class.php(99): Engine->InitModules()
#4 /site/index.php(31): Router->Exec()
#5 {main} thrown in /site/classes/lib/external/DklabCache/Zend/Cache.php on line 141
```

После обновления **PHP** возникла пробелма которая выше… Решается обновлением **pecl-memcache**.

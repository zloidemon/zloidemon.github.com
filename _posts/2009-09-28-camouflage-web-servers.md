---
layout:    post
title:     Маскировка веб серверов
tags:      [ Apache, Nginx, diff, patch, version ]
permalink: /page/maskirovka-veb-serverov
---

**Apache:**

```diff
--- include/ap_release.h.orig   2009-09-28 01:42:28.000000000 +0800
+++ include/ap_release.h        2009-09-28 01:49:33.000000000 +0800
@@ -39,13 +39,13 @@
  *
  * Example: "Apache/1.1.0 MrWidget/0.1-alpha"
  *
-#define AP_SERVER_BASEVENDOR "Apache Software Foundation"
-#define AP_SERVER_BASEPROJECT "Apache HTTP Server"
-#define AP_SERVER_BASEPRODUCT "Apache"
-
-#define AP_SERVER_MAJORVERSION_NUMBER 2
-#define AP_SERVER_MINORVERSION_NUMBER 2
-#define AP_SERVER_PATCHLEVEL_NUMBER   13
+#define AP_SERVER_BASEVENDOR "Satan Software"
+#define AP_SERVER_BASEPROJECT "HELL-WEB"
+#define AP_SERVER_BASEPRODUCT "HELL-WEB"
+
+#define AP_SERVER_MAJORVERSION_NUMBER 6
+#define AP_SERVER_MINORVERSION_NUMBER 66
+#define AP_SERVER_PATCHLEVEL_NUMBER   13
#define AP_SERVER_DEVBUILD_BOOLEAN    0

#if AP_SERVER_DEVBUILD_BOOLEAN
```

Парочка опции в **httpd.conf**

```bash
ServerSignature Off
ServerTokens Prod
```

**nginx:**

```diff
--- src/core/nginx.h.orig       2009-09-28 04:08:56.000000000 +0800
+++ src/core/nginx.h    2009-09-28 04:09:50.000000000 +0800
@@ -8,9 +8,9 @@
#define _NGINX_H_INCLUDED_


-#define nginx_version         7062
-#define NGINX_VERSION      "0.7.62"
-#define NGINX_VER          "nginx/" NGINX_VERSION
+#define nginx_version         6066
+#define NGINX_VERSION      "0.6.66"
+#define NGINX_VER          "hell web server/" NGINX_VERSION

#define NGINX_VAR          "NGINX"
#define NGX_OLDPID_EXT     ".oldbin"

--- src/http/modules/perl/nginx.pm.orig 2009-09-28 04:03:57.000000000 +0800
+++ src/http/modules/perl/nginx.pm      2009-09-28 04:06:02.000000000 +0800
@@ -47,7 +47,7 @@ our @EXPORT = qw(<br>   HTTP_INSUFFICIENT_STORAGE<br> );

-our $VERSION = '0.7.62';
+our $VERSION = '0.6.66';

require XSLoader;
XSLoader::load('nginx', $VERSION);
```

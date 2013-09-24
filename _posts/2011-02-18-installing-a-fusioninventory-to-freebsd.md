---
layout:    post
title:     Installing a FusionInventory to FreeBSD
tags:      [ FusionInventory, FreeBSD, Nginx, ports, PHP ]
permalink: /page/installing-a-fusioninventory-to-freebsd
---

Hi everybody!
This is simple how to install fusioninventory to [FreeBSD]. I missed steps with install a DB.

I have:

```bash
% uname -sr
FreeBSD 8.1-RELEASE
```

I like ports tree :) We will install glpi and plugin from a ports tree ^^

```bash
$portmaster www/nginx www/glpi
$echo nginx_enable=\"YES\">>/etc/rc.conf
$echo php_fpm_enable=\"YES\">>/etc/rc.conf
```

You are can get a [port]

And then try a few steps :-P

```bash
$sh shar-1.sh
$make -C glpi-plugins-fusioninventory-server/ install clean
```

This is my configuration file for a [nginx] virtual host with glpi

```nginx
server {
	listen       80;
	server_name  glpi;
	#    charset utf-8;
	#access_log  logs/host.access.log  main;
	access_log /var/log/nginx.glpi.log;
	error_log /var/log/nginx.error.glpi.log;
	location / {
		root   /usr/local/www/glpi;
		index  index.php index.html index.htm;
	}
	#error_page  404              /404.html;
	# redirect server error pages to the static page /50x.html
	#
	error_page   500 502 503 504  /50x.html;
	location = /50x.html {
		root   /usr/local/www/nginx-dist;
	}
	location ~* \.php$ {
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME /usr/local/www/glpi$fastcgi_script_name;
		include fastcgi_params;
	}
}
```

Now need create a log files and then start services....

```bash
$touch /var/log/nginx.glpi.log
$touch /var/log/nginx.error.glpi.log
$/usr/local/etc/rc.d/php-fpm start
$/usr/local/etc/rc.d/nginx start
```

Done. go to your glpi and activate plugin.

[nginx]: http://www.nginx.org/
[FreeBSD]: http://www.freebsd.org/
[port]: http://www.freebsd.org/cgi/query-pr.cgi?pr=ports/154867

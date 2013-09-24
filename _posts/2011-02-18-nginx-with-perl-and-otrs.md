---
layout:    post
title:     Nginx with Perl and OTRS
tags:      [ OTRS, Nginx, Perl ]
permalink: /page/nginxperlotrs
---

Hi everybody!
I like [nginx]. It's a fast web server! But I need using otrs, without apache and mod_perl. This is my configs for it:

You can install otrs from freebsd ports tree and then use my configs with perl wrapper :)

```bash
$portmaster -d devel/otrs www/nginx www/p5-FastCGI
```

nginx.conf

```nginx

server {
	listen 80;
	server_name localhost;
	root /usr/local/otrs/var/httpd/htdocs;
	access_log  /var/log/nginx/otrs.nginx_access.log;
	index index.html;
	location /otrs-web {
		gzip on;
		alias /usr/local/otrs/var/httpd/htdocs;
	}
	location ~ ^/otrs/(.*\.pl)(/.*)?$ {
		gzip off; #gzip makes scripts feel slower since they have to complete before getting gzipped
		#    fastcgi_pass  unix:/.$1.sock;
		fastcgi_pass unix:/var/run/perl-fcgi.sock;
		#    fastcgi_pass  127.0.0.1:8999;
		fastcgi_index index.pl;
		fastcgi_param SCRIPT_FILENAME   /usr/local/otrs/bin/fcgi-bin/$1;
		fastcgi_param QUERY_STRING      $query_string;
		fastcgi_param REQUEST_METHOD    $request_method;
		fastcgi_param CONTENT_TYPE      $content_type;
		fastcgi_param CONTENT_LENGTH    $content_length;
		fastcgi_param GATEWAY_INTERFACE CGI/1.1;
		fastcgi_param SERVER_SOFTWARE   nginx;
		fastcgi_param SCRIPT_NAME       $fastcgi_script_name;
		fastcgi_param REQUEST_URI       $request_uri;
		fastcgi_param DOCUMENT_URI      $document_uri;
		fastcgi_param DOCUMENT_ROOT     $document_root;
		fastcgi_param SERVER_PROTOCOL   $server_protocol;
		fastcgi_param REMOTE_ADDR       $remote_addr;
		fastcgi_param REMOTE_PORT       $remote_port;
		fastcgi_param SERVER_ADDR       $server_addr;
		fastcgi_param SERVER_PORT       $server_port;
		fastcgi_param SERVER_NAME       $server_name;
	}
}
```

And you need a wrapper for use perl :) You can get it from:

copy [fcgi-wrapper]  to /usr/local/sbin
copy [perl-fcgi] to /usr/local/sbin

And rc.d script

[perl-fcgi.rc] to /usr/local/etc/rc.d/perl-fcgi

then add

```bash
$echo perl_fcgi_enable=\"YES\" >>/etc/rc.conf
```

Thanks [tech notes]

[nginx]: http://www.nginx.org/
[perl-fcgi.rc]: http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/master/scripts/perl-fcgi/perl-fcgi.rc
[fcgi-wrapper]: http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/master/scripts/perl-fcgi/fastcgi-wrapper
[perl-fcgi]: http://gitorious.org/zloidemon-freebsd-configs/trunk/blobs/master/scripts/perl-fcgi/perl-fcgi
[tech notes]: http://technotes.1000lines.net/nginx-perl-fastcgi-how-to/

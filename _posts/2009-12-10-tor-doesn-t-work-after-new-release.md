---
layout:    post
title:     Проблема с tor
tags:      [ Tor, OpenSSL, security, FreeBSD, ports ]
permalink: /page/problema-s-tor
---

В логах:

```bash
Dec 10 19:46:18.539 [notice] Tor 0.2.1.20 opening log file.
Dec 10 19:46:18.540 [notice] Parsing GEOIP file.
Dec 10 19:46:18.705 [warn] We are configured to measure GeoIP statistics, but the way these statistics are measured has changed significantly in later versions of Tor. The results may not be as expected if you are used to later versions.  Be sure you know what you are doing.
Dec 10 19:46:18.994 [notice] No current certificate known for authority moria1; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority tor26; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority dizum; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority ides; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority gabelmoo; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority dannenberg; launching request.
Dec 10 19:46:18.994 [notice] No current certificate known for authority urras; launching request.
Dec 10 19:46:18.994 [notice] Bootstrapped 5%: Connecting to directory server.
Dec 10 19:46:18.994 [notice] I learned some more directory information, but not enough to build a circuit: We have no network-status consensus.
Dec 10 19:46:19.147 [notice] Bootstrapped 10%: Finishing handshake with directory server.
Dec 10 19:46:19.512 [warn] TLS error: unexpected close while renegotiating
Dec 10 19:46:20.046 [warn] TLS error: unexpected close while renegotiating
Dec 10 19:46:20.223 [warn] TLS error: unexpected close while renegotiating
Dec 10 19:46:20.223 [notice] No current certificate known for authority moria1; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority tor26; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority dizum; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority ides; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority gabelmoo; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority dannenberg; launching request.
Dec 10 19:46:20.223 [notice] No current certificate known for authority urras; launching request.
Dec 10 19:46:20.750 [warn] TLS error: unexpected close while renegotiating
Dec 10 19:47:36.560 [notice] Catching signal TERM, exiting cleanly.
```

Нужно поставить **openssl-0.9.8l**:

```bash
%sudo make -C /usr/ports/security/openssl install clean
%sudo portmaster tor-devel
```

---
layout:    post
title:     DTrace integration features
tags:      [ DTrace, FreeBSD, tarantool, OSX, kernel, C ]
---

This is a topic about troubles with integration DTrace in projects. I spent a few days for search bugs and fix its. I'll explain troubles and approach to fixing bugs in the no-sql [tarantool] DB with common instruments.

Topic isn't completed, I'll add new information after fix/found bugs.

Instruments to research:
-----

OSs:

* FreeBSD 9.1-RELEASE-p7
* Darwin 12.5.0
* Linux 3.8.13-16.el6uek.x86_64 (Oracle Linux)

Solaris based:

* OpenIndiana 151a8 (so old compilers)
* Oracle Linux 11.1 (so old compilers)
* SmartOS latest (all stuff got coredump)

DTrace Versions:

* dtrace: Sun D 1.7 (FreeBSD)
* dtrace: Sun D 1.6.2 (Darwin)
* dtrace: Sun D 1.6.3 (Oracle Linux)

Generation DTrace object twice
-----

``` sh
%> sudo dtrace -l -m tarantool_box
Password:
   ID   PROVIDER            MODULE                          FUNCTION NAME
dtrace: failed to match :tarantool_box::: No probe matches description
```

If you have a modular application You'll try to generate many dtrace objects to link that with application. Basically you got static libraries and then linking. This is common approach to programming but If you use dtrace in more than one library you need run second time ```dtrace -G``` for getting one dtrace object which include all providers.

After first time you got a dtrace object with correct information but you would like to get object for all providers in different libs in one object. For example I'll explain main trouble with second time generation.

This is example actually with one library. You are able to do that in command line for getting incorrect object because you did correct object before with information about one:

``` sh
%> dtrace -G -s ../../include/dtrace.d ../CMakeFiles/cjson.dir/third_party/lua-cjson/lua_cjson.c.o -o cjson_dtrace_second.o

%> md5 cjson_dtrace.o
MD5 (cjson_dtrace.o) = 69cc9d1037f106e682464af05205458c
%> md5 cjson_dtrace_second.o
MD5 (cjson_dtrace_second.o) = a42c72ae540be068243936afe2d7b868
```

On above list you see mismatch md5 sums. When I found that I started fire to drill-down to object files and look what's incorrect.

I got 2 dtrace objects, In ```strings``` command I found differences:

``` sh
%> strings -a cjson_dtrace_second.o > dtrace_second
%> strings -a cjson_dtrace.o > dtrace
```

``` sh
%> diff -up dtrace dtrace_second
```

I saw removed functions with dtrace defines for a trace.

``` diff
--- dtrace	2013-09-27 13:47:17.839671510 +0000
+++ dtrace_second	2013-09-27 13:47:08.717669720 +0000
@@ -117,15 +117,10 @@ vfprintf
 encode-done
 char *
 char *
-json_encode
-$dtrace140912.json_encode
 encode-start
 char *
 char *
-json_encode
-$dtrace140912.json_encode
 new-entry
-luaopen_cjson
 tick-start
 tick-stop
 tarantool
```

In the next stage I looked inside ```.SUNW_dof``` in section of dtrace object file.

``` sh
%> objdump -s -j .SUNW_dof cjson_dtrace.o
```

This is correct hex output from dtrace object:


``` text
cjson_dtrace.o:     file format elf64-x86-64-freebsd

Contents of section .SUNW_dof:
 0270 00000000 00000000 00000000 05000000  ................
 0280 01000000 00656e63 6f64652d 646f6e65  .....encode-done
 0290 00696e74 00636861 72202a00 696e7400  .int.char *.int.
 02a0 63686172 202a006a 736f6e5f 656e636f  char *.json_enco
 02b0 64650024 64747261 63653134 30393132  de.$dtrace140912
 02c0 2e6a736f 6e5f656e 636f6465 00656e63  .json_encode.enc
 02d0 6f64652d 73746172 7400696e 74006368  ode-start.int.ch
 02e0 6172202a 00696e74 00636861 72202a00  ar *.int.char *.
 02f0 6a736f6e 5f656e63 6f646500 24647472  json_encode.$dtr
 0300 61636531 34303931 322e6a73 6f6e5f65  ace140912.json_e
 0310 6e636f64 65006e65 772d656e 74727900  ncode.new-entry.
 0320 6c75616f 70656e5f 636a736f 6e007469  luaopen_cjson.ti
 0330 636b2d73 74617274 00696e74 00696e74  ck-start.int.int
 0340 00746963 6b2d7374 6f700069 6e740069  .tick-stop.int.i
 0350 6e740074 6172616e 746f6f6c 00000000  nt.tarantool....
 0360 53756e20 4420312e 37004672 65654253  Sun D 1.7.FreeBS
 0370 44000000 00000000 00000000 00000000  D...............
 0380 00000000 00000000 00000000 00000000  ................
```

Drill-down to next ```incorrect``` object:

``` sh
%> objdump -s -j .SUNW_dof cjson_dtrace_second.o
```


In ```.SUNW_dof``` sect I saw empty dtrace providers for tracing function:


``` text
cjson_dtrace_second.o:     file format elf64-x86-64-freebsd

Contents of section .SUNW_dof:
 0190 00000000 00000000 00000000 05000000  ................
 01a0 01000000 00656e63 6f64652d 646f6e65  .....encode-done
 01b0 00696e74 00636861 72202a00 696e7400  .int.char *.int.
 01c0 63686172 202a0065 6e636f64 652d7374  char *.encode-st
 01d0 61727400 696e7400 63686172 202a0069  art.int.char *.i
 01e0 6e740063 68617220 2a006e65 772d656e  nt.char *.new-en
 01f0 74727900 7469636b 2d737461 72740069  try.tick-start.i
 0200 6e740069 6e740074 69636b2d 73746f70  nt.int.tick-stop
 0210 00696e74 00696e74 00746172 616e746f  .int.int.taranto
 0220 6f6c0000 00000000 53756e20 4420312e  ol......Sun D 1.
 0230 37004672 65654253 44000000 00000000  7.FreeBSD.......
 0240 00000000 00000000 00000000 00000000  ................
```

Next step is finding differences in library objects. After run ```dtrace -G``` to first and second time I got changes in main library objects.


``` sh
%> md5 lua_cjson.c.o
MD5 (lua_cjson.c.o) = bdc0afbb0869f7bee70c29a7ba538127
%> md5 lua_cjson.c.o.dtrace
MD5 (lua_cjson.c.o.dtrace) = 0d65212c87350dceb64f71429b72ce3b
```

I used to do drill-down ```objdump``` but with ``.text``` section in object file because object file holds executable instructions in text section.

``` sh
%> objdump -d -j .text lua_cjson.c.o.dtrace > dtrace
%> objdump -d -j .text lua_cjson.c.o > non-dtrace
````

I used a ```diff``` command to see changes in correct and not modified objects files of library:


``` sh
%> diff -up non-dtrace dtrace
```


``` diff
--- non-dtrace	2013-09-27 13:42:05.811669039 +0000
+++ dtrace	2013-09-27 13:41:59.149669338 +0000
@@ -1,5 +1,5 @@

-lua_cjson.c.o:     file format elf64-x86-64-freebsd
+lua_cjson.c.o.dtrace:     file format elf64-x86-64-freebsd

 Disassembly of section .text:

@@ -11,7 +11,11 @@ Disassembly of section .text:
        c:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
       10:	e8 1b 00 00 00       	callq  30 <lua_cjson_new>
       15:	89 45 f4             	mov    %eax,-0xc(%rbp)
-      18:	e8 00 00 00 00       	callq  1d <luaopen_cjson+0x1d>
+      18:	90                   	nop
+      19:	90                   	nop
+      1a:	90                   	nop
+      1b:	90                   	nop
+      1c:	90                   	nop
       1d:	b8 01 00 00 00       	mov    $0x1,%eax
       22:	48 83 c4 10          	add    $0x10,%rsp
       26:	5d                   	pop    %rbp
@@ -217,7 +221,7 @@ Disassembly of section .text:
      34b:	c3                   	retq
      34c:	0f 1f 40 00          	nopl   0x0(%rax)

-0000000000000350 <json_encode>:
+0000000000000350 <$dtrace140912.json_encode>:
      350:	55                   	push   %rbp
      351:	48 89 e5             	mov    %rsp,%rbp
      354:	48 83 ec 50          	sub    $0x50,%rsp
@@ -227,18 +231,22 @@ Disassembly of section .text:
      365:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
      369:	8b 7d bc             	mov    -0x44(%rbp),%edi
      36c:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
-     370:	e8 00 00 00 00       	callq  375 <json_encode+0x25>
+     370:	90                   	nop
+     371:	90                   	nop
+     372:	90                   	nop
+     373:	90                   	nop
+     374:	90                   	nop
      375:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
-     379:	e8 00 00 00 00       	callq  37e <json_encode+0x2e>
+     379:	e8 00 00 00 00       	callq  37e <$dtrace140912.json_encode+0x2e>
      37e:	b1 01                	mov    $0x1,%cl
      380:	3d 01 00 00 00       	cmp    $0x1,%eax
      385:	88 4d bb             	mov    %cl,-0x45(%rbp)
-     388:	0f 84 21 00 00 00    	je     3af <json_encode+0x5f>
+     388:	0f 84 21 00 00 00    	je     3af <$dtrace140912.json_encode+0x5f>
      38e:	be 01 00 00 00       	mov    $0x1,%esi
      393:	48 8d 14 25 00 00 00 	lea    0x0,%rdx
      39a:	00
      39b:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
-     39f:	e8 00 00 00 00       	callq  3a4 <json_encode+0x54>
+     39f:	e8 00 00 00 00       	callq  3a4 <$dtrace140912.json_encode+0x54>
      3a4:	3d 00 00 00 00       	cmp    $0x0,%eax
      3a9:	0f 95 c1             	setne  %cl
      3ac:	88 4d bb             	mov    %cl,-0x45(%rbp)
@@ -247,13 +255,13 @@ Disassembly of section .text:
      3b6:	81 b9 38 05 00 00 00 	cmpl   $0x0,0x538(%rcx)
      3bd:	00 00 00
      3c0:	88 45 ba             	mov    %al,-0x46(%rbp)
-     3c3:	0f 85 1b 00 00 00    	jne    3e4 <json_encode+0x94>
+     3c3:	0f 85 1b 00 00 00    	jne    3e4 <$dtrace140912.json_encode+0x94>
      3c9:	be 00 00 00 00       	mov    $0x0,%esi
      3ce:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
      3d2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      3d6:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
-     3da:	e8 00 00 00 00       	callq  3df <json_encode+0x8f>
-     3df:	e9 17 00 00 00       	jmpq   3fb <json_encode+0xab>
+     3da:	e8 00 00 00 00       	callq  3df <$dtrace140912.json_encode+0x8f>
+     3df:	e9 17 00 00 00       	jmpq   3fb <$dtrace140912.json_encode+0xab>
      3e4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
      3e8:	48 05 00 05 00 00    	add    $0x500,%rax
      3ee:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
@@ -271,16 +279,20 @@ Disassembly of section .text:
      422:	48 8b 7d f8          	mov    -0x8(%rbp),%rdi
      426:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
      42a:	48 63 55 bc          	movslq -0x44(%rbp),%rdx
-     42e:	e8 00 00 00 00       	callq  433 <json_encode+0xe3>
+     42e:	e8 00 00 00 00       	callq  433 <$dtrace140912.json_encode+0xe3>
      433:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
      437:	81 b8 38 05 00 00 00 	cmpl   $0x0,0x538(%rax)
      43e:	00 00 00
-     441:	0f 85 09 00 00 00    	jne    450 <json_encode+0x100>
+     441:	0f 85 09 00 00 00    	jne    450 <$dtrace140912.json_encode+0x100>
      447:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
-     44b:	e8 00 00 00 00       	callq  450 <json_encode+0x100>
+     44b:	e8 00 00 00 00       	callq  450 <$dtrace140912.json_encode+0x100>
      450:	8b 7d bc             	mov    -0x44(%rbp),%edi
      453:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
-     457:	e8 00 00 00 00       	callq  45c <json_encode+0x10c>
+     457:	90                   	nop
+     458:	90                   	nop
+     459:	90                   	nop
+     45a:	90                   	nop
+     45b:	90                   	nop
      45c:	b8 01 00 00 00       	mov    $0x1,%eax
      461:	48 83 c4 50          	add    $0x50,%rsp
      465:	5d                   	pop    %rbp
```

As seen above, DTrace modifies an object file with use together dtrace and library objects.


Doesn't work multi-PROVIDER in MODULE 
-----

This is next main trouble with integration. It hadn't work anything providers in one module (application). I always got one working provider in application. The trouble related to many dtrace objects which I wanted use when I linked application. If you have a few dtrace objects I'll link its in binary but works only ```first``` provider (depended by position object file in linking proccess).

``` sh
%> cat ../include/dtrace.d
```

Main providers from dtrace file:

``` c
provider coro {
	probe new__entry();
};
provider ev {
	probe tick__start(int flags);
	probe tick__stop(int flags);
};
provider cjson {
	probe encode__start(int len, char *);
	probe encode__done(int len, char *);
	probe new__entry(void *);
};
```

It doesn't work because it was second time to use objects for dtrace. See "Generation DTrace object twice" for more details.

``` sh
%> dtrace -G  -x nolibs -s ../include/dtrace.d  CMakeFiles/ev.dir/third_party/tarantool_ev.c.o CMakeFiles/coro.dir/third_party/coro/coro.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/fpconv.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/lua_cjson.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/strbuf.c.o

%> dtrace -G  -s ../include/dtrace.d  CMakeFiles/ev.dir/third_party/tarantool_ev.c.o CMakeFiles/coro.dir/third_party/coro/coro.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/fpconv.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/lua_cjson.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/strbuf.c.o -o probes.o

%> md5 probes.o dtrace.o
MD5 (probes.o) = bc2c205b019c5e948cfba89ff098c7e8
MD5 (dtrace.o) = bc2c205b019c5e948cfba89ff098c7e8
```

I splitted dtrace file to several ```.d``` files and researched trouble. After that I got a few dtrace objects from correct object files.


``` sh
%> dtrace -G  -s ../include/dtrace.d  CMakeFiles/cjson.dir/third_party/lua-cjson/fpconv.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/lua_cjson.c.o CMakeFiles/cjson.dir/third_party/lua-cjson/strbuf.c.o -o dtrace/cjson_dtrace.o

%> cat ../third_party/lua-cjson/cjson_dtrace.d
```

``` c
provider cjson {
	probe encode__start(int len, char *);
	probe encode__done(int len, char *);
	probe new__entry(void *);
};
```

``` sh
%> dtrace -G  -s ../third_party/libev/ev_dtrace.d  CMakeFiles/ev.dir/third_party/tarantool_ev.c.o -o dtrace/ev_dtrace.o

%> cat ../third_party/libev/ev_dtrace.d
```

``` c
provider ev {
	probe tick__start(int flags);
	probe tick__stop(int flags);
};
```

``` sh
%> dtrace -G  -s ../third_party/coro/coro_dtrace.d  CMakeFiles/coro.dir/third_party/coro/coro.c.o -o dtrace/coro_dtrace.o
%> cat ../third_party/coro/coro_dtrace.d
```

``` c
provider coro {
	probe new__entry();
};
```

It worked when I linked by one dtrace object in the end of line:

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/cjson_dtrace.o
```

Providers works in module:

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571 cjson43089     tarantool_box                       json_encode encode-done
56572 cjson43089     tarantool_box                       json_encode encode-start
56573 cjson43089     tarantool_box                     luaopen_cjson new-entry
56574 cjson43090     tarantool_box                       json_encode encode-done
56575 cjson43090     tarantool_box                       json_encode encode-start
56576 cjson43090     tarantool_box                     luaopen_cjson new-entry
```

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/ev_dtrace.o
```

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571    ev42775     tarantool_box                            ev_run tick-start
56572    ev42775     tarantool_box                            ev_run tick-stop
56573    ev42776     tarantool_box                            ev_run tick-start
56574    ev42776     tarantool_box                            ev_run tick-stop
```

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/core_dtrace.o

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571  coro43386     tarantool_box                         coro_init new-entry
56572  coro43387     tarantool_box                         coro_init new-entry
```

It shows main trouble with linking all ```*.o``` dtrace objects. If want try that You'll get only one working provider because it linked with sorted objects and first is cjson by alphabet.

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/*.o
```

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571 cjson43681     tarantool_box                       json_encode encode-done
56572 cjson43681     tarantool_box                       json_encode encode-start
56573 cjson43681     tarantool_box                     luaopen_cjson new-entry
56574 cjson43682     tarantool_box                       json_encode encode-done
56575 cjson43682     tarantool_box                       json_encode encode-start
56576 cjson43682     tarantool_box                     luaopen_cjson new-entry
```

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/coro_dtrace.o ../../dtrace/ev_dtrace.o ../../dtrace/cjson_dtrace.o
```

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571  coro43978     tarantool_box                         coro_init new-entry
56572  coro43979     tarantool_box                         coro_init new-entry
```

``` sh
%> /usr/local/bin/clang++33    -fno-omit-frame-pointer -fno-stack-protector -fexceptions -funwind-tables -std=c++11 -fno-rtti -Wall -Wextra -Wno-sign-compare -Wno-strict-aliasing    CMakeFiles/tarantool_box.dir/tuple.cc.o CMakeFiles/tarantool_box.dir/tuple_convert.cc.o CMakeFiles/tarantool_box.dir/tuple_update.cc.o CMakeFiles/tarantool_box.dir/key_def.cc.o CMakeFiles/tarantool_box.dir/index.cc.o CMakeFiles/tarantool_box.dir/hash_index.cc.o CMakeFiles/tarantool_box.dir/tree_index.cc.o CMakeFiles/tarantool_box.dir/bitset_index.cc.o CMakeFiles/tarantool_box.dir/space.cc.o CMakeFiles/tarantool_box.dir/port.cc.o CMakeFiles/tarantool_box.dir/request.cc.o CMakeFiles/tarantool_box.dir/txn.cc.o CMakeFiles/tarantool_box.dir/box.cc.o CMakeFiles/tarantool_box.dir/lua/box.lua.c.o CMakeFiles/tarantool_box.dir/lua/box_net.lua.c.o CMakeFiles/tarantool_box.dir/lua/misc.lua.c.o CMakeFiles/tarantool_box.dir/lua/sql.lua.c.o CMakeFiles/tarantool_box.dir/box_lua.cc.o CMakeFiles/tarantool_box.dir/box_lua_space.cc.o CMakeFiles/tarantool_box.dir/__/__/cfg/tarantool_box_cfg.c.o -o tarantool_box libltbox.a ../../cfg/libcfg.a ../libcore.a ../../libev.a ../../libeio.a ../../libcoro.a ../../libgopt.a ../../libcjson.a ../../third_party/luajit/src/libluajit.a ../../libmisc.a -lpthread -lintl -lelf ../lib/bitset/libbitset.a ../lib/bit/libbit.a -L/usr/local/lib ../../dtrace/ev_dtrace.o ../../dtrace/coro_dtrace.o ../../dtrace/cjson_dtrace.o
```

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
56571    ev44268     tarantool_box                            ev_run tick-start
56572    ev44268     tarantool_box                            ev_run tick-stop
56573    ev44269     tarantool_box                            ev_run tick-start
56574    ev44269     tarantool_box                            ev_run tick-stop
```

The trouble solved with use one common dtrace object for all libs. You need to run:

```
dtrace -G -s file.d *.o -o common.o
```

And then link libs, objects and common.o to binary.


Doesn't work wildcards
-----

I fixed first list of troubles, but I had strange result. Wildcards doesn't work for all providers. 

Ready to use providers in module:

``` sh
%> sudo dtrace -l -m tarantool_box
   ID   PROVIDER            MODULE                          FUNCTION NAME
 2789  coro23800     tarantool_box                         coro_init new-entry
 2790    ev23800     tarantool_box                            ev_run tick-start
 2791    ev23800     tarantool_box                            ev_run tick-stop
 2792 cjson23800     tarantool_box                       json_encode encode-done
 2793 cjson23800     tarantool_box                       json_encode encode-start
 2893  coro23798     tarantool_box                         coro_init new-entry
 2894    ev23798     tarantool_box                            ev_run tick-start
 2895    ev23798     tarantool_box                            ev_run tick-stop
 2896 cjson23798     tarantool_box                       json_encode encode-done
 2897 cjson23798     tarantool_box                       json_encode encode-start
```

If I had file.d which contained: 

``` c
provider cjson {
	probe new__entry();
	probe encode__start();
	probe encode__done(int len, char *);
};
provider coro {
	probe new__entry();
};
provider ev {
	probe tick__start(int flags);
	probe tick__stop(int flags);
};
````

I would got only one working ```cjson*:```:

``` sh
%> sudo dtrace -n 'cjson*::json_encode:encode-done'
dtrace: description 'cjson*::json_encode:encode-done' matched 2 probes
CPU     ID                    FUNCTION:NAME
 1      4          json_encode:encode-done
 0      4          json_encode:encode-done
 1      4          json_encode:encode-done
 1      4          json_encode:encode-done
^C
```

Empty results for another providers in module:

``` sh
%> sudo dtrace -n coro*:::

^C
```

It trouble related to position providers in ```file.d```.

Not fixed in [FreeBSD], You have to use one name for all providers:

``` sh
%> sudo dtrace -l -m tarantool_box
   ID   PROVIDER            MODULE                          FUNCTION NAME
56571 tarantool75366     tarantool_box                       json_encode encode-done
56572 tarantool75366     tarantool_box                       json_encode encode-start
56573 tarantool75366     tarantool_box                     luaopen_cjson new-entry
56574 tarantool75366     tarantool_box                         coro_init new-entry
56575 tarantool75366     tarantool_box                            ev_run tick-start
56576 tarantool75366     tarantool_box                            ev_run tick-stop
56577 tarantool75367     tarantool_box                       json_encode encode-done
56578 tarantool75367     tarantool_box                       json_encode encode-start
56579 tarantool75367     tarantool_box                     luaopen_cjson new-entry
56580 tarantool75367     tarantool_box                         coro_init new-entry
56581 tarantool75367     tarantool_box                            ev_run tick-start
56582 tarantool75367     tarantool_box                            ev_run tick-stop
````

Providers doesn't work if someone doesn't use
-----

If you defined a lot of provider in D file, but someone of providers doesn't use in code all providers doesn't work.

For example you have:

``` c
provider lua_cjson {
       probe start();
       probe end(int, char *);
};
provider coro {
       probe new__entry();
};
provider ev {
       probe tick__start(int flags);
       probe tick__stop(int flags);
}
```

But provider ```lua_cjson``` and ```coro``` doesn't use in code but defined in D file. You'll have:

``` sh
%> sudo dtrace -l -m tarantool_box
Password:
   ID   PROVIDER            MODULE                          FUNCTION NAME
dtrace: failed to match :tarantool_box::: No probe matches description
```

If you change file as below:

``` c
provider ev {
       probe tick__start(int flags);
       probe tick__stop(int flags);
};
```

Then run tarantool again you'll have:

``` sh
%> sudo dtrace -l -m tarantool_box
   ID   PROVIDER            MODULE                          FUNCTION NAME
56642    ev32305     tarantool_box                            ev_run tick-start
56643    ev32305     tarantool_box                            ev_run tick-stop
```

This is bug on FreeBSD and Oracle Linux.


Kernel panic by empty MODULE
-----

If you run application You'll get access to providers:

``` sh
%> sudo dtrace -l -m tarantool_box
  ID   PROVIDER            MODULE                          FUNCTION NAME
   4  cjson2015     tarantool_box                       json_encode encode-done
   5  cjson2015     tarantool_box                       json_encode encode-start
   6  cjson2015     tarantool_box                     luaopen_cjson new-entry
   7   coro2015     tarantool_box                         coro_init new-entry
   8     ev2015     tarantool_box                            ev_run tick-start
   9     ev2015     tarantool_box                            ev_run tick-stop
  10  cjson2016     tarantool_box                       json_encode encode-done
  11  cjson2016     tarantool_box                       json_encode encode-start
  12  cjson2016     tarantool_box                     luaopen_cjson new-entry
  13   coro2016     tarantool_box                         coro_init new-entry
  14     ev2016     tarantool_box                            ev_run tick-start
  15     ev2016     tarantool_box                            ev_run tick-stop
```

But If you run ```dtrace -m tarantool_box``` and then shutdown tarantool_box You'll get kernel panic:


``` text
#>  kgdb kernel.debug /var/crash/vmcore.0
GNU gdb 6.1.1 [FreeBSD]
Copyright 2004 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "amd64-marcel-freebsd"...

Unread portion of the kernel message buffer:
kernel trap 12 with interrupts disabled


Fatal trap 12: page fault while in kernel mode
cpuid = 1; apic id = 01
fault virtual address	= 0xfffffdffd8ecf3e2
fault code		= supervisor read data, page not present
instruction pointer	= 0x20:0xffffffff81a4a7fd
stack pointer	        = 0x28:0xffffff80d53119d0
frame pointer	        = 0x28:0xffffff80d53119f0
code segment		= base 0x0, limit 0xfffff, type 0x1b
			= DPL 0, pres 1, long 1, def32 0, gran 1
processor eflags	= resume, IOPL = 1
current process		= 2023 (tarantool_box)
trap number		= 12
panic: page fault
cpuid = 1
KDB: stack backtrace:
#0 0xffffffff809538a6 at kdb_backtrace+0x66
#1 0xffffffff8091ac8e at panic+0x1ce
#2 0xffffffff80c17990 at trap_fatal+0x290
#3 0xffffffff80c17cfc at trap_pfault+0x21c
#4 0xffffffff80c182f5 at trap+0x365
#5 0xffffffff80c025f3 at calltrap+0x8
#6 0xffffffff81cb15fd at fasttrap_fork+0x27d
#7 0xffffffff808eaea9 at fork1+0x1519
#8 0xffffffff808ebc12 at sys_fork+0x22
#9 0xffffffff80c1713a at amd64_syscall+0x5ea
#10 0xffffffff80c028d7 at Xfast_syscall+0xf7
Uptime: 5m12s
Dumping 356 out of 3001 MB:..5%..14%..23%..32%..41%..54%..63%..72%..81%..95%

.... Loading modules skipped ....

#0  doadump (textdump=Variable "textdump" is not available.
) at pcpu.h:224
224		__asm("movq %%gs:0,%0" : "=r" (td));
(kgdb) list *0xffffffff81a4a7fd
0xffffffff81a4a7fd is in dtrace_assfail (/usr/src/sys/modules/dtrace/dtrace/../../../cddl/contrib/opensolaris/uts/common/dtrace/dtrace.c:603).
598	}
599
600	int
601	dtrace_assfail(const char *a, const char *f, int l)
602	{
603		dtrace_panic("assertion failed: %s, file: %s, line: %d", a, f, l);
604
605		/*
606		 * We just need something here that even the most clever compiler
607		 * cannot optimize away.
(kgdb) backtrace
#0  doadump (textdump=Variable "textdump" is not available.
) at pcpu.h:224
#1  0xffffffff8091a771 in kern_reboot (howto=260) at /usr/src/sys/kern/kern_shutdown.c:448
#2  0xffffffff8091ac67 in panic (fmt=0x1 <Address 0x1 out of bounds>) at /usr/src/sys/kern/kern_shutdown.c:636
#3  0xffffffff80c17990 in trap_fatal (frame=0xc, eva=Variable "eva" is not available.
) at /usr/src/sys/amd64/amd64/trap.c:857
#4  0xffffffff80c17cfc in trap_pfault (frame=0xffffff80d5311920, usermode=0) at /usr/src/sys/amd64/amd64/trap.c:773
#5  0xffffffff80c182f5 in trap (frame=0xffffff80d5311920) at /usr/src/sys/amd64/amd64/trap.c:456
#6  0xffffffff80c025f3 in calltrap () at /usr/src/sys/amd64/amd64/exception.S:228
#7  0xffffffff81a4a7fd in dtrace_assfail (a=0xffffffff81cb4bc6 "cp->p_dtrace_count == 0", f=0xfffffe005721a81c "coro*", l=Variable "l" is not available.
)
    at /usr/src/sys/modules/dtrace/dtrace/../../../cddl/contrib/opensolaris/uts/common/dtrace/dtrace.c:603
#8  0xffffffff81cb15fd in fasttrap_fork (p=0xfffffe00a83b64a0, cp=0xfffffe005711d940)
    at /usr/src/sys/modules/dtrace/fasttrap/../../../cddl/contrib/opensolaris/uts/common/dtrace/fasttrap.c:479
#9  0xffffffff808eaea9 in fork1 (td=0xfffffe002b730470, flags=20, pages=Variable "pages" is not available.
) at /usr/src/sys/kern/kern_fork.c:694
#10 0xffffffff808ebc12 in sys_fork (td=0xfffffe002b730470, uap=Variable "uap" is not available.
) at /usr/src/sys/kern/kern_fork.c:110
#11 0xffffffff80c1713a in amd64_syscall (td=0xfffffe002b730470, traced=0) at subr_syscall.c:135
#12 0xffffffff80c028d7 in Xfast_syscall () at /usr/src/sys/amd64/amd64/exception.S:387
#13 0x0000000801731a7c in ?? ()
```

markj@ send me [FIX] panic. I'm planing to try patch.

DTrace in tarantool
-----

Pre release of DTrace in [tarantool]. If you run box.cjson.encode() function, You'll able to see data for encoding and len. 

Example commands in command line tarantool client: 


``` text
127.0.0.2> lua box.cjson.encode({test= 'xzvfvzcvzx'})
---
 - {"test":"xzvfvzcvzx"}
...
127.0.0.2> lua box.cjson.encode({test= 'xzvfvzcvzx'})
---
 - {"test":"xzvfvzcvzx"}
...
127.0.0.2> lua box.cjson.encode({test= 'xzvfvzcvzx'})
---
 - {"test":"xzvfvzcvzx"}
...
127.0.0.2> lua box.cjson.encode({test= 'xzvfvzsafzx'})
---
 - {"test":"xzvfvzsafzx"}
...
127.0.0.2> lua box.cjson.encode({test= 'xx'})
---
 - {"test":"xx"}
...
127.0.0.2> lua box.cjson.encode({tmasfasdf= 'xx'})
---
 - {"tmasfasdf":"xx"}
...
```

DTrace in action:

``` sh
%> sudo dtrace -n 'tarantool*:json_encode:encode-start { self->ts = timestamp; } tarantool*:json_encode:encode-done { printf("%s time: %d", copyinstr(arg1),
 ((timestamp - self->ts)/1000)); }'
dtrace: description 'tarantool*:json_encode:encode-start ' matched 4 probes
CPU     ID                    FUNCTION:NAME
  1  56611          json_encode:encode-done {"test":"xzvfvzcvzx"}x"} time: 10
  1  56611          json_encode:encode-done {"test":"xzvfvzcvzx"}x"} time: 10
  1  56611          json_encode:encode-done {"test":"xzvfvzcvzx"}x"} time: 7
  1  56611          json_encode:encode-done {"test":"xzvfvzsafzx"}"} time: 10
  1  56611          json_encode:encode-done {"test":"xx"}vzsafzx"}"} time: 9
  1  56611          json_encode:encode-done {"tmasfasdf":"xx"}zx"}"} time: 9
```

Patched tarantool available in the repo [tarantool-dtrace].


DTrace probes at runtime
-----

This is very intersting task, I found [libusdt] with [lua-usdt] bindings and tried that in [tarantool-dtrace]. I had great result on OSX and FreeBSD but on Oracle Linux doesn't work.

Exaple of usage:

After run application you had only static providers which which below:

```sh
%> sudo dtrace -l -m tarantool_box
   ID   PROVIDER            MODULE                          FUNCTION NAME
 1578   lua54178     tarantool_box                               foo iprobe
 4031    ev54179     tarantool_box                            ev_run tick-start
 4032    ev54179     tarantool_box                            ev_run tick-stop
 4132    ev54178     tarantool_box                            ev_run tick-start
 4133    ev54178     tarantool_box                            ev_run tick-stop
```

Then you connected and try to use a USDT providers at realtime:

```sh
%> ~/tmp/tt-dtrace/bin/tarantool
localhost> usdt
---
- provider: 'function: 0x094ca2b0'
...
localhost> provider = usdt.provider("lua", "tarantool_box")
---
...
localhost> iprobe = provider:probe("foo", "iprobe", "int")
---
...
localhost> provider:enable()
---
...
```

If you run DTrace you'll see available probes at realtime:

```sh
%> sudo dtrace -n 'lua*:tarantool_box:foo:iprobe { printf("%d", arg0)}'
dtrace: description 'lua*:tarantool_box:foo:iprobe ' matched 1 probe
```

Time to fire!

```sh
localhost> iprobe:fire(1)
---
...
localhost> iprobe:fire(2)
---
...
localhost> iprobe:fire(4)
---
...
localhost> iprobe:fire(200)
---
...
localhost>
```

You must see probes at realtime:

```sh
%> sudo dtrace -n 'lua*:tarantool_box:foo:iprobe { printf("%d", arg0)}'
dtrace: description 'lua*:tarantool_box:foo:iprobe ' matched 1 probe
CPU     ID                    FUNCTION:NAME
  1   1578                       foo:iprobe 1
  0   1578                       foo:iprobe 2
  1   1578                       foo:iprobe 4
  1   1578                       foo:iprobe 200
```

Unfortunately doesn't work on Oracle Linux. Also FreeBSD have a bug with USDT probes where probes more than 5 arguments.

CMake automation
----

Integration with CMake or another build tools is painful because you need do ```dtrace -G``` for one or many objects.
But that doesn't need do on OSX, this is best way and more convenient. See example with full hack: 

``` cmake
set(cjson_obj)
 
add_library(cjson_objs OBJECT lua_cjson.c strbuf.c ${FPCONV_SOURCES})
set_target_properties(cjson_objs PROPERTIES POSITION_INDEPENDENT_CODE ON)
set(cjson_obj ${cjson_obj} $<TARGET_OBJECTS:cjson_objs>)
 
if(ENABLE_DTRACE AND DTRACE)
    message(STATUS "DTrace found and enabled")
    add_definitions(-DENABLE_DTRACE)
    set(D_FILE ${PROJECT_SOURCE_DIR}/cjson_dtrace)
    execute_process(
       COMMAND ${DTRACE} -h -s ${D_FILE}.d -o ${D_FILE}.h
    )
    if(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
        set(cjson_obj_2 ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/cjson_objs.dir/lua_cjson.c.o)
        set(dtrace_obj ${CMAKE_CURRENT_BINARY_DIR}/dtrace.o)
        add_custom_command(OUTPUT ${dtrace_obj}
            COMMAND ${DTRACE} -G -s ${D_FILE}.d -o ${dtrace_obj} ${cjson_obj_2}
            DEPENDS ${cjson_obj_2}
        )
        set_source_files_properties(${dtrace_obj}
            PROPERTIES
            EXTERNAL_OBJECT true
            GENERATED true
        )
        set(cjson_obj ${cjson_obj} ${dtrace_obj})
        unset(cjson_obj_2)
        unset(dtrace_obj)
        unset(D_FILE)
    endif()
endif()
 
add_library(cjson MODULE ${cjson_obj})
set_target_properties(cjson PROPERTIES PREFIX "")
target_link_libraries(cjson ${_MODULE_LINK})
```

DTrace on FreeBSD
-----

DTrace have a lot bugs but works with any limits.

Bug list:

* Wildcards bug
* USDT at runtime works only with probes with arguments less than 5
* USDT depended by base src because need ```dtrace.h``` although It exists on OSX and Oracle Linux
* Bug with providers position in D file with multi link dtrace objects
* Bug with not used probes when all providers unavailable if doesn't use in code

DTrace on Oracle Linux
-----

DTrace on [Oracle Linux] doesn't work fine. I found a few bugs similar as on FreeBSD.

Bug list:

* USDT doesn't work
* Bug with providers position in D file with multi link dtrace objects
* Bug with not used probes when all providers unavailable if doesn't use in code

DTrace on OSX
-----

Bug list:

* Not found


Conclusions
-----

The best platform for DTrace is OSX now. 

DTrace on OSX more convenient than FreeBSD/Solaris because It has modified toolchain. You need only use:

```dtrace -h -s file.d -o header.h```

And then include ```header.h``` in C code and compile binary file. 



[FreeBSD]:   http://FreeBSD.org   "The main OS"
[FIX]:       http://svnweb.freebsd.org/base/head/sys/cddl/contrib/opensolaris/uts/common/dtrace/fasttrap.c?r1=254198&r2=254197&pathrev=254198 "Fix panic"
[tarantool]: http://tarantool.org "The Tarantool project"
[tarantool-dtrace]: https://github.com/tarantool/tarantool/tree/dtrace "DTrace in tarantool"
[Oracle Linux]: http://linux.oracle.com/RELEASE-NOTES-UEK3-BETA-en.html "Oracle Linux UEK3"
[libusdt]: https://github.com/chrisa/libusdt "libusdt"
[lua-usdt]: https://github.com/chrisa/lua-usdt "lua-usdt"

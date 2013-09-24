---
layout:    post
title:     SFTP на базе ProFTPD с пользователями в PostgreSQL
tags:      [ SFTP, ProFTPD, PostgreSQL, ports, FreeBSD ]
permalink: /page/sftp-na-baze-proftpd-s-polzovateljami-v-pgsql
---

Прочитал много всевозможных статей (не будем показывать пальцем где, это и так все знают), причем во всех было хранение паролей в открытом виде, и вообще мало что связанное с безопасной передачей данных. Вроде все знаем что это не хорошо, но продолжаем делать глупые ошибки.
Мой выбор пал на proftpd с поддержкой SFTP, но как оказалось в портах не реализована поддержка, но это не помеха...

Патч берем либо с официального сайта, либо с моей репы.

```text
http://www.freebsd.org/cgi/query-pr.cgi?pr=143018
http://gitorious.org/zloidemon-freebsd-ports/trunk/blobs/master/patches/patch_sftp-proftpd-devel-1.3.3rc2
```

Дальше патчим и тд:

```bash
%cp -R /usr/ports/ftp/proftpd-devel ./
%patch -p0 <patch_sftp-proftpd-devel-1.3.3rc2
%sudo make -C proftpd-devel/ config-recursive install clean
# вообщем с опциями там будет все понятно, что и для чего нужно
```

Писать про установку pgsql я пока не собираюсь, про это и так достаточно написано. Так что перейдем к работе с самой базой данных.

```bash
%createuser -S -D -R -P files
%createdb -O files sftp
%psql -U files -d sftp
```

```sql
sftp=> CREATE TABLE users (id serial PRIMARY KEY,sftpuser varchar(20),passwd text,uid int,gid int,home varchar(70),shell varchar(20));
#на что там выдаст
NOTICE:  CREATE TABLE создаст подразумеваемую последовательность "users_id_seq" для serial-колонки "users.id"
NOTICE:  CREATE TABLE / PRIMARY KEY создаст подразумеваемый индекс "users_pkey" для таблицы "users"
CREATE TABLE
#смотрим что имеем
sftp=> \d
                 List of relations
 Schema |     Name     |   Type   |      Owner
--------+--------------+----------+-----------------
 public | users        | table    | files.zlonet.ru
 public | users_id_seq | sequence | files.zlonet.ru
(2 rows)
```

Покажу свой конфиг proftpd, но это не означает что его нужно копировать, он и так почти весь default:

```text
ServerName                      "Server from HELL"
ServerType                      standalone        
DefaultServer                   on
Port                            21

#UseIPv6                                off
Umask                           022

MaxInstances                    30

User                            nobody                   
Group                           nogroup

DefaultRoot ~ 
AllowOverwrite          on

<Limit SITE_CHMOD>                
  DenyAll                         
</Limit>

SQLAuthTypes            OpenSSL
SQLBackend              postgres
SQLAuthenticate         users
SQLConnectInfo          sftp@localhost files megapass
SQLUserInfo             users sftpuser passwd uid gid home shell
RequireValidShell       off
SQLLogFile              /var/log/proftpd_sql.log

MaxClients              20 "Sorry Max Clients"
MaxClientsPerHost       10 "Max client from your host"
MaxLoginAttempts        5 "Max Login Attmps"

SyslogLevel             notice
UseReverseDNS           off

SFTPEngine      On
SFTPHostKey     /etc/ssh/ssh_host_rsa_key
SFTPHostKey     /etc/ssh/ssh_host_dsa_key
```

Собственно комментировать тут нечего, и так все понятно, если что надо можно заглянуть в установленную с proftpd документацию.

Добавление пользователей, для этого написал скрипт, так как вломы генерирова SHA1 ложить в БД и тд.
Берем скрипт из репы

```text
http://gitorious.org/zloidemon-dev/trunk/blobs/master/createftpuser/src/createftpuser.py
```

Для него понадобиться python и модуль:

```bash
%sudo make -C /usr/ports/databases/py-sqlalchemy config-recursive install clean
#собираем с поддержкой pgsql
```

Сам скрипт прокомментировал достаточно хорошо, так что настроить его для работы с вашей любимой БД не составит труда.

Пример работы:

```bash
./createftpuser.py
Adding new user

user :blah
password :test
uid :14
gid :14
home dir :/var/ftp
shell :
New user info:
user : blah
password : test
uid: 14
gid 14
home: /var/ftp
shell: /bin/sh
add new user y/n :y
```

После работы скрипта можно посмотреть что создалось в БД:

```sql
sftp=> SELECT * FROM users;
 id | sftpuser |               passwd               | uid | gid |   home   |  shell
----+----------+------------------------------------+-----+-----+----------+---------
  1 | blah     | {SHA1}qUqP5cyxm6YcTAhz05Hph5gvu9M= |  14 |  14 | /var/ftp | /bin/sh
(1 запись)
```

Учитывая данные созданные в таблице, создаем пользователя в системе (в моем случае все пользователи из БД работают от ftp:ftp, которого можно создать через sysinstall).

Подключаемся:

```bash
%sftp -oPort=21 blah@host#адрес или домен удаленного сервера.
Connecting to host...
The authenticity of host '[host]:21 ([host]:21)' can't be established.
RSA key fingerprint is ea:33:59:2c:40:74:7b:a1:18:de:fd:a1:21:fd:bf:e3.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[host]:21' (RSA) to the list of known hosts.
blah@host's password:
sftp> ls
etc       incoming  pub
```

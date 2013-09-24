---
layout:    post
title:     Установка junos 10 на PC
tags:      [ JunOS, Juniper, FreeBSD, diff, patch, boot, kernel, sysctl ]
permalink: /page/ustanovka-junos-10-na-pc
---

Устанавливал JunOS я непосредственно в 7.3-RELEASE-i386-bootonly.iso.
Первое на что нужно обратить внимание, так это на разделение slice на partition. Если не создавать partition /tmp, то возникает ошибка об нехватке свободного места на носителе md1, который в свою очередь имеет объём 160Mb.

Нужно установить минимальную версию FreeBSD на носитель, и приступить к созданию модифицированного пакета.

```bash
$cd /var/tmp
Кладем package сюда удобным для вас способом.... И приступаем к модификации.
$mkdir blah;cd blah;tar zxvf ../jinstall-10.1R1.8-domestic-signed.tgz
$mkdir blah;cd blah;tar zxvf ../jinstall-10.1R1.8-domestic.tgz

$mkdir blah;cd blah;tar zxvf ../pkgtools.tgz
$cp -v /usr/bin/true bin/checkpic

$tar zcvf ../pkgtools.tgz *
$cd ../;rm -rf blah
$tar zcfv /var/tmp/jinstall-10.1R1.8-domestic.tgz *
Устанавливаем:
$pkg_add -f jinstall-10.1R1.8-domestic.tgz
$echo console=\"vidconsole\">>/boot/loader.conf;reboot
```

Ожидаем окончания установки и радуемся:

```bash
root@%cli
root>show version
Model: olive
JUNOS Base OS boot [10.1R1.8]
JUNOS Base OS Software Suite [10.1R1.8]
JUNOS Kernel Software Suite [10.1R1.8]
JUNOS Crypto Software Suite [10.1R1.8]
JUNOS Packet Forwarding Engine Support (M/T Common) [10.1R1.8]
JUNOS Packet Forwarding Engine Support (M20/M40) [10.1R1.8]
JUNOS Online Documentation [10.1R1.8]
JUNOS Voice Services Container package [10.1R1.8]
JUNOS Border Gateway Function package [10.1R1.8]
JUNOS Services AACL Container package [10.1R1.8]
JUNOS Services LL-PDF Container package [10.1R1.8]
JUNOS Services Stateful Firewall [10.1R1.8]
JUNOS AppId Services [10.1R1.8]
JUNOS IDP Services [10.1R1.8]
JUNOS Routing Software Suite [10.1R1.8]
```

PS:

1. В internet полно трактатов по установке olive на PC, но там старые версии, и для них не нужно создавать partition /tmp в slice.
2. HDD обязательно должен иметь имя ad0[s]X, либо нужно делать symlinks.
3. Минимальный объём оперативной памяти 512M, но потом можно вставить HDD после установки в другой системный блок. Я использую junos на 256M, но заметны проблемы при запуске cli и других команд.


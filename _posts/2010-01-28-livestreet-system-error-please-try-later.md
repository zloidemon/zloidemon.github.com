---
layout:    post
title:     'livestreet: Системная ошибка, повторите позже'
tags:      [ error, PHP, downgrade, FreeBSD, SphinxSearch, LiveStreet ]
permalink: /page/livestreet-sistemnaja-oshibka-povtorite-pozzhe
---

Такое радужное сообщение я увидел после обновления **textproc/sphinxsearch**.

<blockquote>Системная ошибка, повторите позже</blockquote>
Потратил около двух часов на решение этой проблемы... Все работало на ура но, не возвращалось на страницу, те было просто пусто.
Оказалось все невероятно просто. Криворукость программистов снова дала о себе знать. Оно просто не совместимо с новой версией, что еще довольно сильно охлодило отношение к этому проекту.

Решение:

```bash
%sudo make -C /usr/ports/ports-mgmt/portdowngrade
%portdowngrade sphinxsearch -s anoncvs@anoncvs1.FreeBSD.org:/home/ncvs
```

Дальше все понятно жмем цифры которые нам надо, и выбираем 0.9.8 версию.
Дальше:

```bash
%sudo pkg_delete sphinxsearch-\*
%sudo -C /usr/ports/textproc/sphinxsearch install clean
```

Ну дальше все по старинке, индексируем и тд.
Вывод напросился только один... А если будет не совместимость с чем-то более важным, да и еще требовать уязвимую версию? Вот будет то забавно не обновиться, и быть подверженным атакам.

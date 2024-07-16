---
title: Root-me - Web Server - File Upload - Null Byte
meta_title: ""
description: Uplodez du code PHP dans ce file upload.
date: 2024-16-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Web
  - Moyen
author: Emma.exe
tags:
  - Web
  - Rootme
draft: false
---

## Introduction

Le but de ce challenge est d'upload un fichier contenant du code PHP.

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Résolution

{{< tabs >}} {{< tab "Niveau 1" >}}

Commencez par vous renseigner sur le titre du challenge. Ce dernier donne déjà beaucoup d'informations sur la façon dont on doit résoudre ce challenge.

Pour la partie "code PHP", pas besoin de créer un script complexe, un simple `phpinfo()` devrait suffire.

{{< /tab >}}

{{< tab "Niveau 2" >}}

Pour résoudre ce challenge, on utilise la vulnérabilité Null-Byte. Pour cela, on insère un null-byte dans le nom du fichier pour donner par exemple :  `example.php%00.jpg`

Le `%00` va faire que le .jpg sera occulté (car il s'agit d'un caractère de fin de chaine).

On crée un fichier nommé `example.php%00.jpg` contenant du code php tel que : 
```php
<?php phpinfo(); />
```

On accède ensuite à la ressource en retirant le .jpg : 

```
http://challenge01.root-me.org/web-serveur/ch22/galerie/upload/3e01ab43ababbeeee94e7f182e808357/example.php
```

Et on obtient le flag !

{{< /tab >}}{{< /tabs >}}

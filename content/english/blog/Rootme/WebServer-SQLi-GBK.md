---
title: Root-me - SQLi - GBK
meta_title: ""
description: Retrouvez le mot de passe de l'administrateur.
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

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}


## Résolution
{{< tabs >}} {{< tab "Niveau 1" >}}

Tout d'abord, il est important de savoir ce que signifie "GBK".
Il s'agit du jeu de caractères chinois.
Tous les caractères spéciaux chinois commencent par 0xBF puis forment un caractère avec les bytes qui suivent.
Trouvez des caractères spéciaux chinois qui terminent par une valeur qui pourrait être aussi interprété en unicode.
Jouez avec ces caractères pour bypass l'authentification.

Le cas échéant, trouver des ressources sur Internet qui peuvent vous aider.

{{< /tab >}}

{{< tab "Niveau 2" >}}
Le jeu de caractères GBK est celui des caractères chinois. Les caractères spéciaux chinois commencent par 0xBF puis forment un caractère avec les bytes qui suivent.
Et notamment 0xBF5C, où 5C est aussi un antislash en unicode. 
Ainsi, si on insère des valeurs de type `test\xbf' UNION SELECT`, et qu'elles sont ensuite nettoyés par une fonction d'échappement, on obtiendra : `test\xbf\' UNION SELECT`.
Si SQL s'attend à recevoir du GBK, il traitera `\xbf\xc5` comme un caractère chinois.

Ainsi la requête devient `test[cxaractère chinois]' UNION SELECT`. Il est donc possible de passer outre l'échappement des quotes.

Ensuite on fait une requête tel que 1=1 ou `database() LIKE 0x2525` autrement dit `le nom de la database contient zéro ou plusieurs caractères`. (le 0x2525 revient à dire `%%`).

Source : https://bases-hacking.org/injections-sql-avancees.html
```
"尐' OR database() LIKE 0x2525 -- ";
```
OU
```
"尐' OR 1=1 -- ";
```

{{< /tab >}}{{< /tabs >}}

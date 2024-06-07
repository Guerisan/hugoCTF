
---
title: Root-me - Capture-moi ça
meta_title: ""
description: Retrouvez le mot de passe perdu de ce KeePass grâce à une image PNG.
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Emma.exe
tags:
  - Forensic
  - Rootme
draft: false
---

# Introduction

Ce challenge Root-me se présente sous la forme d'une image PNG et d'une Base de données KDBX.

L'utilisateur a perdu son mot de passe KeePass et notre mission est de le retrouver.

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

{{< tabs >}} {{< tab "Niveau 1" >}}

- La catégorie de ce challenge est **Forensic** et non **Brute-Force** ou **Hashcat**.
- Analyser les deux fichiers afin de trouver des anomalies. Vous pouvez par exemple utiliser **pngcheck** pour en apprendre plus sur cette image.

{{< /tab >}}

{{< tab "Niveau 2" >}}

Pour résoudre ce challenge, j'ai tout d'abord commencer par essayer de bruet-force le KeePass, sans grand succès.

En effet, ce n'est pas dans le KeePass que réside la faille mais dans l'image PNG ! 

Avec pngcheck, on peut voir que des données sont présentes dans l'image après le chunk IEND, qui est censé marqué la fin de l'image.

On sait aussi qu'il s'agit d'une capture d'écran Windows.

En combinant ces deux informations dans une recherche, on tombe sur la vulnérabilité **Acropalypse**.

Il s'agit d'une vulnérabilité affectant notamment les OS Windows. 
Lorsqu'une capture d'écran est "cropé" ou rogné, la donné au sein de l'image n'est pas supprimé, seul le IEND est déplacé.

Cela rend ainsi possible la restauration de l'image de base.

J'ai personnellement utilisé l'outil **Acropalypse-Multi-Tool** disponible sur Github : https://github.com/frankthetank-music/Acropalypse-Multi-Tool.

Il s'utilise avec une interface graphique : 
```
python3 gui.py
```

Il ne nous reste plus qu'à restaurer l'image à l'aide de l'outil pour découvrir le mot de passe du Keepass.
A l'intérieur se trouve le flag.

{{< /tab >}}
{{< /tabs >}}


---
title: Root-me - Oh My Grub 
meta_title: ""
description: Retrouvez les dossiers de cette machine Linux sans avoir le mot de passe.
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Emma.exe
tags:
  - Forensic
  - Rootme
  - Linux
draft: false
---

Dans ce challenge root-me, notre société a perdu les accès à un serveur Linux.
On nous demande de retrouver des documents importants.

Le challenge se compose d'un fichier ova. Il s'agit d'une machine virtuelle qu'il suffit d'importer dans VirtualBox.

Lorsque l'on démarre la machine cela nous demande d'entrer un login/mdp. Or nous ne le connaissons pas.

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

{{< tabs >}} {{< tab "Niveau 1" >}}

**Exploitation** : 
- Renseignez vous sur qu'est le **GRUB** sous Linux
- Effectuez quelques recherches sur votre moteur de recherche favori afin de comprendre comment procède les administrateurs systèmes qui perdent le mot de passe de leurs machines.

**Recherche du flag** :
- Lorsque vous afficher le contenu d'un dossier, affichez-vous vraiment tous les fichiers ?

{{< /tab >}}

{{< tab "Niveau 2" >}}

1. Au démarrage appuyez sur la touche 'e' afin d'entrer dans la configuration du GRUB
2. A la ligne qui commence par "linux", ajoutez à la fin de celle-ci `init=/bin/bash`
3. Appuyez sur CTRL+X pour redémarrer la machine
4. Vous avez désormais accès au bash et vous pouvez passer à la recherche du flag
5. Celui se trouve dans un fichier caché dans le dossier `/root`.

{{< /tab >}}
{{< /tabs >}}

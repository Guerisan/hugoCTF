---
title: 404CTF - Vaut mieux sécuriser que guérir 
meta_title: ""
description: this is meta description
date: 2024-04-04T05:00:00Z
image: /images/image-placeholder.png
categories:
  - Application
  - Data
author: Emma.exe
tags:
  - forensic
  - volatility
draft: false
---

# Vaut mieux sécuriser que guérir

Le challenge nous est donné sous la forme d'une dump de mémoire de Windows.
L'outil idéal pour effectuer de l'analyse sur ce genre de fichier est volatility.

Volatility existe en deux versions : la 2 et la 3.
La 3 est encore en cours de construction mais est plus facile à utiliser et à installer que la 2. C'est cette version que j'ai utilisé pour résoudre ce challenge.

Avec volatility, on commence par faire un pstree.

```sh
vol.py -f memory.dmp windows.pstree.PsTree
```

Grâce à cette commande, on peut voir tous les processus qui tournaient au moment où la capture de mémoire a été prise.
L'un d'entre eux sort du lot : on remarque un powershell suspect qui lance une socket.

On extrait avec memmap le processus.

```sh
vol.py -f memory.dmp windows.memmap.Memmap --pid 4852 
```

Cette commande nous permet d'extraire la totalité des commandes qui ont été passées dans ce processus Powershell.

Il y a ainsi beaucoup de données à analyser. On peux tenter de taper quelques mots clés comme "History", "ps1" ou d'autres noms de commandes Powershell afin de trouver des résultats.

Cela nous permet de voir que dans l'historique powershell, un fichier "hacked.ps1" a été supprimé.
On sait que le deuxième flag est le nom d'une tâche, on recherche donc "New-ScheduledTask", la cmdlet Powershell associée à la création de tâches planifiées.
On trouve la tâche qui a été crée : 
{{< image src="Pasted image 20240424113156.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}} 

En remontant, on trouve aussi le script qui a été supprimé, et ainsi la chaine de caractère : 
{{< image src="Pasted image 20240424113342.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Cette partie du hash est "chiffré". L'alternance de chiffre et de lettres majuscules et minuscules nous permet de dire qu'il s'agit probablement de base64.

On la décode depuis la Base64, on associe les deux et on trouve le flag.

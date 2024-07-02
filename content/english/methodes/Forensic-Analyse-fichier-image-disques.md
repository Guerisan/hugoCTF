
---
title: Forensic - Analyse de fichiers images disques Windows
meta_title: ""
description: Méthodologie d'analyse forensic pour les fichiers images Windows
date: 2024-07-01T05:00:00Z
image: /images/forensic.svg
categories:
  - Méthodes
author: Emma.exe
tags:
  - Méthodes
  - Fiches
  - Forensic
draft: false
---

Le but de cette fiche méthode est de vous fournir une méthodologie à suivre dans le cas d'une analyse d'image disque Windows.

## Image disques

Premièrement, une image disque est une sauvegarde complète d'un ou plusieurs disques.
Généralement, lorsqu'on analyse un ordinateur, on effectue systématiquement une copie de celui-ci afin de ne pas altérer les données présentes sur la machine. 
Cette copie du disque peut ensuite être analysée sans risque.

## Outillage

Pour réaliser cette analyse nous allons avoir besoin de plusieurs outils : 
- The Sleuth Kit, une collection d'outils permettant l'analyse des images disques
- PECmd de EricZimmerman, un parser de fichier Prefetch
- RegRipper pour l'analyse du registre

## Analyse

### Liste des partitions

Afin d'analyser l'image disque, il faut commencer par lister les partitions à l'intérieur de celle-ci afin de choisir la bonne.
Pour cela on utilise en premier `mmls` de The Sleuth Kit.
```sh
mmls usb.image
```

Exemple d'output : 
```sh
DOS Partition Table
Units are in 512-byte sectors

     Slot    Start        End          Length       Description
00:  Meta    0000000000   0000000000   0000000001   Primary Table (#0)
01:  -----   0000000000   0000000062   0000000063   Unallocated
02:  00:00   0000000063   0002056319   0002056257   Basic Data partition
```

Dans ce cas, nous allons choisir d'analyser la partition 2 nommé Basic Data partition car c'est sûrement celle qui contient les informations importantes.

### Système de fichiers

On peut ensuite utiliser la commande `fsstat` afin de connaître le système d'exploitation.
Pour cela, on précise le début de la partition qui nous intéresse (63) avec l'option `-o`.
```sh
fsstat -o 63 usb.image 
```

Exemple de résultat : 
```sh
FILE SYSTEM INFORMATION
--------------------------------------------
File System Type: NTFS
Volume Serial Number: 6814485614482980
OEM Name: NTFS
Version: Windows XP

METADATA INFORMATION
--------------------------------------------
First Cluster of MFT: 786432
First Cluster of MFT Mirror: 2
Size of MFT Entries: 1024 bytes
Size of Index Records: 4096 bytes
Range: 0 - 119040
Root Directory: 5

CONTENT INFORMATION
--------------------------------------------
Sector Size: 512
Cluster Size: 4096
Total Cluster Range: 0 - 15644158
Total Sector Range: 0 - 125153278

$AttrDef Attribute Values:
$STANDARD_INFORMATION (16)   Size: 48-72   Flags: Resident
$ATTRIBUTE_LIST (32)   Size: No Limit   Flags: Non-resident
$FILE_NAME (48)   Size: 68-578   Flags: Resident,Index
$OBJECT_ID (64)   Size: 0-256   Flags: Resident
$SECURITY_DESCRIPTOR (80)   Size: No Limit   Flags: Non-resident
$VOLUME_NAME (96)   Size: 2-256   Flags: Resident
$VOLUME_INFORMATION (112)   Size: 12-12   Flags: Resident
$DATA (128)   Size: No Limit   Flags:
$INDEX_ROOT (144)   Size: No Limit   Flags: Resident
$INDEX_ALLOCATION (160)   Size: No Limit   Flags: Non-resident
$BITMAP (176)   Size: No Limit   Flags: Non-resident
$REPARSE_POINT (192)   Size: 0-16384   Flags: Non-resident
$EA_INFORMATION (208)   Size: 8-8   Flags: Resident
$EA (224)   Size: 0-65536   Flags:
$LOGGED_UTILITY_STREAM (256)   Size: 0-65536   Flags: Non-resident
```

### Timeline 
Pour commencer, nous allons nous servir de la commande `fls`, faisant partie de The Sleuth Kit (TSK) afin de créer une timeline des fichiers.
Il affiche notamment des informations sur des fichiers supprimés.
Cette commande se base sur la table MFT de Windows.

Voici comment lancer cette commande :
```sh
fls -r -mc -o 63 usb.image > timeline.txt
```

Les résultats sont stockés au format "body" : https://wiki.sleuthkit.org/index.php?title=Body_file

C'est-à-dire :
```sh
 MD5 | path/name | device | inode | mode_as_value | mode_as_string | num_of_links
 | UID | GID | rdev | size | atime | mtime | ctime | block_size | num_of_blocks
```

Exemple de ligne : 
```sh
0|/wusagedl.exe|0|6|33279|-/-rwxrwxrwx|1|0|0|0|3827200|1220846400|1216831874|1216831874|512|0
```

Comme vous pouvez le voir, le format de `fls` est difficilement lisible pour un être humain.
Pour palier ce problème, un autre outil a été créer : mactime.
Celui-ci créer une timeline dans un format plus lisible en se basant sur l'output de fls :
```sh
mactime -b timeline.txt > mactime-timeline.txt

Xxx Xxx 00 0000 00:00:00        0 ..c. r/rrwxrwxrwx 0        0        3        c/USB         (Volume Label Entry)
                           246064 ..c. r/rrwxrwxrwx 0        0        5        c/anonyme.png (deleted)
Sun Sep 12 2021 00:00:00        0 .a.. r/rrwxrwxrwx 0        0        3        c/USB         (Volume Label Entry)
                           246064 .a.. r/rrwxrwxrwx 0        0        5        c/anonyme.png (deleted)
Sun Sep 12 2021 15:05:36   246064 m... r/rrwxrwxrwx 0        0        5        c/anonyme.png (deleted)
Sun Sep 12 2021 15:11:26        0 m..b r/rrwxrwxrwx 0        0        3        c/USB         (Volume Label Entry)
Sun Sep 12 2021 15:11:52   246064 ...b r/rrwxrwxrwx 0        0        5        c/anonyme.png (deleted)
```

### Extraction des données
Cette timeline va nous permettre de comprendre ce qu'il s'est passé en terme de fichiers.
Par exemple, si nous souhaitons analyser un fichier qui a été supprimé ou un exécutable suspect qui été créer, on peut utiliser la commande `icat` afin d'extraire le fichier de l'image.

Pour cela nous allons avoir besoin de son ID, qui est spécifié à la Xe colonne de l'output de mactime.

Extraction du fichier :
```sh
icat -o 0 usb.image 5 > anonyme.png
```

### Analyse d'un fichier malware

Si vous avez extrait un fichier suspect qui ressemble à un malware, on peut tenter de pivoter avec VirusTotal grâce au hash du malware : 
```sh
certutil -hashfile filename sha256
sha256sum filename
```

Lancer une recherche sur VirusTotal afin d'obtenir plus d'informations sur le fichier : est-il connu pour être malveillant ? Possède-t-il d'autres noms ?

### Analyse Prefetch

Prefetch est un système de cache Windows sous la forme de fichiers possédant l'extension pf.
Ils se trouvent dans le dossier `C:\Windows\Prefetch`.
Son but est d'optimiser l'exécution des applications Windows.
Cependant, il peut contenir de nombreuses informations intéressantes pour notre analyse forensique.

On peut notamment utiliser l'outil `PECmd` pour les analyser.
Dans un premier temps, récupérer les fichiers Prefetch avec `icat`, puis lancer l'analyse : 
```sh
PECmd.exe -f filename.pf
```

On peut désormais comparer les dates afin de connaitre la véritable date de première exécution. La timeline

### Analyse du registre

Afin d'analyser le registre, il faut dans un premier temps extraire les différentes ruches.
Voici la liste des fichiers intéressants :
- `/Users/*/AppData/Local/Microsoft/Windows/USERCLASS.dat`
- `/Users/*/NTUSER.dat`
- `/Windows/System32/Config/SAM`
- `/Windows/System32/Config/SECURITY`
- `/Windows/System32/Config/SOFTWARE`
- `/Windows/System32/Config/SYSTEM`

Avec ces fichiers, on peut analyser plusieurs choses intéressantes.
La première : les shellbags. 
Il s'agit d'artéfacts qui permettent de suivre les affichages, les tailles et les emplacements de la fenêtre d'un dossier dans l'Explorer. Ils sont utilisé pour déterminer les activités utilisateurs sur le système.

```sh
rip -r USERCLASS.dat -p shellbags
```

Autre analyse intéressante : l'historique USB : 
```sh
rip.exe -r SYSTEM -p usbstor > usbstor.txt
```

Analyse des disques et points de montage :
```sh
rip.exe -r SYSTEM -p mountdev > mountdev.txt
```

Analyse des programmes récemment exécutés sur le système grâce à l'userassist :
```sh
rip.exe -r NTUSER.DAT -p userassist > userassist.txt
```

Analyse des document récents d'un utilisateur :
```sh
rip.exe -r NTUSER.DAT -p recentdocs > recentdocs.txt
```

Analyse des réseaux :
```sh
rip.exe -r SOFTWARE -p networklist > networklist.txt
```

Voilà pour les principales fonctionnalités de RegRipper, vous pouvez lister les autres plugins disponibles avec la commande : 
```sh
rip.exe -l
```

### Pour aller plus loin

Pour aller plus loin, vous pouvez visiter le github de EricZimmerman qui a fournit bon nombre d'outils orienté forensic : https://github.com/EricZimmerman/

Vous pouvez aussi consulter d'autres de nos articles sur la forensic : 
- Les challenges forensic : https://guerisan.github.io/hugoCTF/categories/forensic/
- Fiches pratique sur Volatility : https://guerisan.github.io/hugoCTF/outils/volatility/

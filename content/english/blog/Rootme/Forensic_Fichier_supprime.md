---
title: Rootme - Fichier supprimé
meta_title: ""
description: this is meta description
date: 2024-04-04T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Facile
author: Alexis
tags:
  - "#forensic"
draft: false
---
L'objectif du challenge est de trouver le nom et le prénom du propriétaire de la clé usb en analysant son dump

On commence par regarder le type de dump
``` bash
file usb.image 
usb.image: DOS/MBR boot sector, code offset 0x3c+2, OEM-ID "mkfs.fat", sectors/cluster 4, reserved sectors 4, root entries 512, sectors 63488 (volumes <=32 MB), Media descriptor 0xf8, sectors/FAT 64, sectors/track 62, heads 124, hidden sectors 2048, reserved 0x1, serial number 0xc7ecde5b, label: "USB        ", FAT (16 bit)
```

Ensuite avec la commande "fls" on peut lister les fichiers et répertoires du dump
``` bash
fls usb.image 
r/r 3:	USB         (Volume Label Entry)
r/r * 5:	anonyme.png
v/v 1013699:	$MBR
v/v 1013700:	$FAT1
v/v 1013701:	$FAT2
V/V 1013702:	$OrphanFiles
alexis@alexis-HP-EliteBook-8
```

Sur la sortie de "fls", les fichiers supprimés sont marqués par des "\*". On voit une fichier anonyme.png qui a été supprimé. On va donc l'extraire pour l'analyser

"icat" permet d'extraire des fichiers en se basant sur son nombre d'inode, dans notre cas c'est 5 pour extraire l'image
``` bash
icat usb.image 5 > image.png
```

On va analyser les méta données de cette image avec exiftool
``` bash
exiftool image.png 
ExifTool Version Number         : 12.40
File Name                       : image.png
Directory                       : .
File Size                       : 240 KiB
...
Background Color                : 255 255 255
XMP Toolkit                     : Image::ExifTool 11.88
Creator                         : Javier Turcot
Image Size                      : 400x300
Megapixels                      : 0.120
```

Dans le résultat on trouve l'auteur de l'image qui est "Javier Turcot" et cela correspond au flag que l'on cherche
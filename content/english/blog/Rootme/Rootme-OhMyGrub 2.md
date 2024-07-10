
---
title: Root-me - Oh My Grub 
meta_title: ""
description: Retrouvez les dossiers de cette machine Linux sans avoir le mot de passe.
date: 2024-07-10T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Professeur_Jack
tags:
  - Forensic
  - Rootme
  - Linux
draft: false
---

{{< notice "tip" >}} Ceci est une résolution alternative à la [solution proposée par Emma.txt](blog/rootme/rootme-ohmygrub/). N'hésitez-pas à y jeter un coup d'oeil avant ! {{< /notice >}}

[Lien du challenge](https://www.root-me.org/fr/Challenges/Forensic/Oh-My-Grub)

Les accès à un serveur ont été perdus, mais les fichiers qui se trouvaient dessus sont toujours convoités.
On nous fournit l'image virtuelle de la machine (un fichier au format **.ova**)
S'il n'est pas chiffré, on va essayer d'extraire le disque pour monter le Filesystem sur notre propre machine et l'explorer tranquillement.
## A partir du fichier .ova

OVA est un format de compression, on va commencer par l'extraire
```sh
tar -xvf nom_du_fichier.ova
ls 
-rw-r----- 1 jack users 279M août  12  2019 root-disk001.vmdk
-rw------- 1 jack users 279M août  12  2019 root.ova
-rw-r----- 1 jack users 8,0K août  12  2019 root.ovf
```

## On convertit le disque, et on le monte.

Nous avons bien un fichier de disque !

On passe le `.vmbk` en `raw` pour pouvoir le monter.
```sh
qemu-img convert -f vmdk root-disk001.vmdk -O raw disk.raw
```
Mais si on le monte tel quel, on reçoit des erreurs : 
```sh
sudo mkdir /mnt/disk
sudo mount -o loop nom_du_fichier.raw /mnt/disk

 mount: /mnt/disque: mauvais type de système de fichiers, option erronée, superbloc erroné sur /dev/loop0, page de code ou programme auxiliaire manquant, ou autre erreur.
       dmesg(1) peut avoir plus d'informations après un échec de l'appel système du montage.
```

Le disque contient en effet vraisemblablement plusieurs partitions, que l'ont confirme avec `fdisk` :
```sh
sudo fdisk -l disk.raw
Disque disk.raw : 8 GiB, 8589934592 octets, 16777216 secteurs
Unités : secteur de 1 × 512 = 512 octets
Taille de secteur (logique / physique) : 512 octets / 512 octets
taille d'E/S (minimale / optimale) : 512 octets / 512 octets
Type d'étiquette de disque : dos
Identifiant de disque : 0x49b6eb9f

Périphérique Amorçage    Début      Fin Secteurs Taille Id Type
disk.raw1    *            2048 15988735 15986688   7,6G 83 Linux
disk.raw2             15990782 16775167   784386   383M  5 Étendue
disk.raw5             15990784 16775167   784384   383M 82 partition d'échange Linux / Solaris
```

C'est la première qui nous intéresse ici, avec le Filesystem linux.
> Le début de la partition disk.raw1 est à 2048 secteurs. Chaque secteur fait 512 octets.
```sh
echo $((2048 * 512))
1048576

sudo mount -o loop,offset=1048576 disk.raw /mnt/disk
```

Le disque est monté avec succès cette fois-ci :
```sh
[root@JackdawNix:/mnt/disk]# l
total 84K
drwxr-xr-x 18 root root 4,0K août  12  2019 .
drwxr-xr-x  3 root root 4,0K juil. 10 16:18 ..
drwxr-xr-x  2 root root 4,0K juil. 16  2019 bin
drwxr-xr-x  3 root root 4,0K juil. 16  2019 boot
drwxr-xr-x  4 root root 4,0K juil. 16  2019 dev
drwxr-xr-x 55 root root 4,0K août  12  2019 etc
drwxr-xr-x  3 root root 4,0K juil. 16  2019 home
lrwxrwxrwx  1 root root   29 juil. 16  2019 initrd.img -> /boot/initrd.img-3.16.0-6-586
drwxr-xr-x 14 root root 4,0K juil. 16  2019 lib
drwx------  2 root root  16K juil. 16  2019 lost+found
drwxr-xr-x  3 root root 4,0K juil. 16  2019 media
drwxr-xr-x  2 root root 4,0K juil. 16  2019 opt
drwxr-xr-x  2 root root 4,0K juin  17  2018 proc
drwx------  2 root root 4,0K août  12  2019 root
drwxr-xr-x  2 root root 4,0K juil. 16  2019 run
drwxr-xr-x  2 root root 4,0K août  12  2019 sbin
drwxr-xr-x  2 root root 4,0K avril  6  2015 sys
drwxr-xr-x  5 root root 4,0K août  12  2019 usr
drwxr-xr-x  4 root root 4,0K août  12  2019 var
lrwxrwxrwx  1 root root   25 juil. 16  2019 vmlinuz -> boot/vmlinuz-3.16.0-6-586
```

Dans le répertoire *root/* se trouve un fichier *.bash_history*. Un bon point de départ pour nous indiquer ce qu'on pourait trouver sur la machine.
```
cd /root/
l
pwd
ls
nano .passwd
ls
ls -ahr
ls -alh
chmod 400 .passwd 
[...]
```
On voit que le fichier .passwd a probablement été modifié. Il n'y a plus qu'à l'ouvrir et....

Flag !
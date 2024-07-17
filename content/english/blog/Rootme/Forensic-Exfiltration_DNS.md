---
title: Root-me - Exfiltration DNS
meta_title: ""
description: 
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Tmax
tags:
  - Forensic
  - Rootme
draft: false
---

# Introduction

Pour ce challenge, nous allons devoir analyser un pcap.

{{< tabs >}} {{< tab "Niveau 1" >}}

- Vous avez bien lu la description du challenge ? Les ressources également ? Le titre ? 


{{< /tab >}}

{{< tab "Niveau 2" >}}

Après avoir récupéré le pcap, on peut l'ouvrir avec Wireshark. On constate que le domaine `jz-n-bs.local` est utilisé pour les requêtes DNS. 

Généralement, la technique utilisée est d'envoyer plusieurs requêtes vers un domaine DNS où le nom du serveur destinataire de cette requête n'est en fait que la données encodées en base64 ou en hexadecimal. 

On peut utiliser `tshark` récupérer ces données : 

```bash
tshark -r ch21.pcap -T fields -e dns.qry.name | uniq | sed 's/.jz-n-bs.local//g' | xxd -r -p > test.txt 
```

On remarque que j'ai des en-tête PNG comme "png" "hdr" "idat" "tEND", mais impossible de l'ouvrir en tant que PNG. 

En ouvrant le fichier avec `hexeditor`, on constate une sorte de surplus, ce qui cause la corruption du PNG. 

On va essayer de résoudre ce problème. 

```bash
tshark -r ch21.pcap -T fields -e dns.qry.name | uniq | sed 's/.jz-n-bs.local//g' > test.txt 
```

Si on analyse ce fichier, on constate que les 18 premiers caractères de chaque requêtes DNS se ressemblent énormément. Ce qui apparaît comme étant l’identifiant unique de chaque requête. [RFC DNS](https://datatracker.ietf.org/doc/html/rfc1035#section-4.1.4)

Donc, maintenant que l'on sait ça : 

```bash
tshark -r ch21.pcap -T fields -e dns.qry.name | uniq | sed 's/.jz-n-bs.local//g'| tr -d "."  | sed 's/^.\{18\}//' | tr -d '\n' > stage1.txt
```

```bash
cat stage1.txt| xxd -r -p > stage2.png
```

On utilise `binwalk` pour récupérer le png. 

```bash
binwalk -D 'image:png' stage2.png
```

```bash
open _stage2.png.extracted/8.png 
```


{{< /tab >}}
{{< /tabs >}}
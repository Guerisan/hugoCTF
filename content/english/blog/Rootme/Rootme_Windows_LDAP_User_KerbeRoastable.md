---
title: Rootme - Windows - LDAP User KerbeRoastable
meta_title: ""
description: Le challenge Root-me Windows - LDAP User KerbeRoastable est un challenge Forensic qui consiste en l'exploration d'un fichier JSON extrait d'un AD afin de retrouver les comptes kerberoastable.
date: 2024-04-04T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Forensic
  - Facile
author: Emma.exe
tags:
  - forensic
draft: false
---

Le challenge se présente sous la forme d'un fichier JSON.
A l'intérieur se trouve un extract d'un AD, qui a été réalisé grâce à l'outil `ldap2json` : https://github.com/p0dalirius/ldap2json.

On nous demande de trouver l'utilisateur qui est KerbeRoastable, le flag étant son mail.

## Fonctionnement de Kerberos et du Kerberoasting

Premièrement, que signifie Kerberoastable ?
Si vous ne connaissez pas bien le fonctionnement de Kerberos, je vous conseille cette documentation : https://beta.hackndo.com/kerberos/.
Dans les grandes lignes, Kerberos est le service d'authentification Microsoft.
Il fonctionne grâce à l'attribution de ticket, garantissant l'accès à une ou plusieurs ressources.
Pour chaque ressource, nous avons besoin d'un ticket spécifique appelé TGS (Ticket Granting Service).
Mais avant de pouvoir demander un TGS, il nous faut d'abord demandé un TGT (Ticket Granting Tickets). Il s'agit d'un ticket nous permettant de demander des TGS.
Pour demander un TGT il faut d'abord s'authentifier.

Lors de la demande du ticket de service auprès du contrôleur de domaine, aucun contrôle n'est effectué pour vérifier si l'utilisateur dispose des autorisations nécessaires pour accéder au service hébergé par le SPN.

Ces vérifications ne sont effectuées dans un deuxième temps que lors de la connexion au service lui-même. Cela signifie que si nous connaissons le SPN que nous voulons cibler, nous pouvons demander un ticket de service pour lui au contrôleur de domaine.

## Résolution du challenge

Pour la résolution de ce challenge, je vous propose deux niveaux d'aide. Le premier niveau vous donne des pistes de résolution, sans donner la solution, tandis que le second niveau donne un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

{{< tabs >}} {{< tab "Niveau 1" >}}

- Comme indiqué dans le challenge, vous pouvez utiliser l'outil **ldap2json**, mais pas uniquement. Vu qu'il s'agit d'un fichier JSON, vous pouvez tout aussi bien l'explorer manuellement ou le parser avec sed ou grep.
- Trouvez un moyen de l'identifier les comptes possédant un attribut `servicePrincipalName`. 

{{< /tab >}} {{< tab "Niveau 2" >}}

Voici un exemple de résolution utilisant l'outil ldap2json :

1. Charger le fichier dans ldap2json :
```sh
$ ./analysis.py -f ../ch31.json
[>] Loading ../ch31.json ... done.
```

2. Rechercher les `servicePrincipalName` :
```sh
[]> object_by_property_name servicePrincipalName
[CN=krbtgt,CN=Users,DC=ROOTME,DC=local] => servicePrincipalName
 - ['kadmin/changepw']
[CN=Alexandria,CN=Users,DC=ROOTME,DC=local] => servicePrincipalName
 - ['HTTP/SRV-RDS.rootme.local']
[CN=DC01,OU=Domain Controllers,DC=ROOTME,DC=local] => servicePrincipalName
 - ['Dfsr-12F9A27C-BF97-4787-9364-D31B6C55EB04/DC01.ROOTME.local', 'ldap/DC01.ROOTME.local/ForestDnsZones.ROOTME.local', 'ldap/DC01.ROOTME.local/DomainDnsZones.ROOTME.local', 'DNS/DC01.ROOTME.local', 'GC/DC01.ROOTME.local/ROOTME.local', 'RestrictedKrbHost/DC01.ROOTME.local', 'RestrictedKrbHost/DC01', 'RPC/55de6b37-27e0-4d8e-84f1-b54018a48b62._msdcs.ROOTME.local', 'HOST/DC01/ROOTME', 'HOST/DC01.ROOTME.local/ROOTME', 'HOST/DC01', 'HOST/DC01.ROOTME.local', 'HOST/DC01.ROOTME.local/ROOTME.local', 'E3514235-4B06-11D1-AB04-00C04FC2DCD2/55de6b37-27e0-4d8e-84f1-b54018a48b62/ROOTME.local', 'ldap/DC01/ROOTME', 'ldap/55de6b37-27e0-4d8e-84f1-b54018a48b62._msdcs.ROOTME.local', 'ldap/DC01.ROOTME.local/ROOTME', 'ldap/DC01', 'ldap/DC01.ROOTME.local', 'ldap/DC01.ROOTME.local/ROOTME.local'] 
```

3. On remarque que l'utilisateur Alexandria possède cet attribut. On énumère ses autres attributs pour trouver son mail :
```sh
object_by_dn CN=Alexandria,CN=Users,DC=ROOTME,DC=local
```

{{< /tab >}} {{< /tabs >}}

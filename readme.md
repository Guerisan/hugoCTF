<h1 align="center">Hugoctf by LeGroupe4 - 2600</h1>

<p align="center">Ce dépôt contient toutes les sources nécessaires à la construction de notre site web : Capture the Flag for Beginners 🚩</p>

## 🚀 Getting Started

Tout d'abord, vous devez cloner ce repo. 

### ⚙️ Prerequisites

Pour commencer à utiliser ce template en local, vous devez avoir installé certains prérequis sur votre machine.

- [Hugo Extended v0.124+](https://gohugo.io/installation/)
- [Node v20+](https://nodejs.org/en/download/)
- [Go v1.22+](https://go.dev/doc/install)

### 👉 Project Setup

```bash
npm run project-setup
```

### 👉 Installation des dépendances

Installez toutes les dépendances à l'aide de la commande suivante.

```bash
npm install
```

### 👉 Development Command

Démarrez le serveur de développement à l'aide de la commande suivante.

```bash
npm run dev
```

L'url par défaut se trouve à http://localhost:1313

Chaque modification faite dans les pages de contenu impacte automatiquement le résultat. Le site s'actualise tout seul.

---

## 🚀 Build And Deploy

Après avoir terminé votre développement, vous pouvez construire ou déployer votre projet presque partout. Voyons le processus :

### 👉 Build Command

Pour construire votre projet localement, vous pouvez utiliser la commande suivante. Elle purgera tous les CSS inutilisés et minifiera tous les fichiers.

```bash
npm run build
```

### 👉 Déployer le site avec Github Action 

Nous avons fait le choix d'utiliser Github Action pour rendre accessible ce site. 
Voici les étapes que nous avons réalisées : 

Visitez votre dépôt GitHub. Dans le menu principal, choisissez **Paramètres** > **Pages**. Au centre de votre écran, vous verrez ceci => Changez la **Source** en `GitHub Actions`. Le changement est immédiat, vous n'avez pas besoin d'appuyer sur le bouton Enregistrer.

La commande `npm run project-setup` à déjà ajoutée un fichier de Workflow sous `.github/workflows`. 

Modifiez l'url de Base dans `./hugoCTF/hugo.toml`. 

```
baseURL = "https://guerisan.github.io/hugoCTF/"
```

Il ne reste plus qu'à commit, puis regarder dans "Actions" sur github si le build de la pipeline s'est bien passé.  

---

## 📝 Edition d'un article !

Tous les markdowns sont contenus dans le seul dossier **content/**. 
C'est notre dossier de travail principal.

```
➤ tree
english
    ├── about
    │   └── _index.md
    ├── authors
    │   ├── _index.md
    │   ├── john-doe.md
    │   ├── sam-wilson.md
    │   └── william-jacob.md
    ├── blog
    │   ├── forensic-darts
    │   │   ├── assets/image-1.jpeg
    │   │   └── Forensic.md
    │   ├── _index.md
    │   ├── post-1.md
    │   └── post-2.md
    └─── contact
        └── _index.md

```

Pour ajouter un write-up, il suffit de de partir d'un fichier markdown vierge, puis d'ajouter ces métadonnées au sommet du fichier :

```toml
---
title: Awesome forensic lvl 1
meta_title: ""
description: this is meta description
date: 2024-04-04T05:00:00Z
image: /images/image-placeholder.png
categories:
  - Application
  - Data
author: John Doe
tags:
  - forensic
  - volatility
draft: false
---
```

## 🔒 Protéger une page avec un mot de passe

Nous utilisons un petit script qui nous sert à entrer des mots de passe pour accéder aux write-ups protégés.

Ajouter le contenu suivant à la fin du fichier `themes/hugoplate/assets/js/main.js`

```js

async function sha1(message) {
  // Convert the message string to a Uint8Array
  const msgBuffer = new TextEncoder().encode(message);

  // Hash the message
  const hashBuffer = await crypto.subtle.digest('SHA-1', msgBuffer);

  // Convert ArrayBuffer to Array
  const hashArray = Array.from(new Uint8Array(hashBuffer));

  // Convert bytes to hex string
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}

let button = document.getElementsByClassName('level-3');

if (button) {
  button[0].addEventListener('click', function (e) {
    e.preventDefault();
    let password = prompt("The password :");
    console.log(password)
    login(password)
  })
}

function login(secret) {
  sha1(secret).then(hash => {
    console.log("hash:", hash);
    const currentUrl = window.location.pathname;
    let newUrl = currentUrl.replace(/\/[^\/]*\/?$/, "");
    const url = newUrl + "/" + hash;
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    console.log("Good");
    request.onload = function () {
      if (request.status >= 200 && request.status < 400) {
        window.location = window.location.origin + url;
      } else {
        alert("Password Incorrect");
      }
    };
    request.send();
  }).catch(error => {
    console.error("Error hashing password:", error);
  });
}

```

A présent, on peut générer un *sha1* à partir d'un mot de passe ou d'un flag qui servira d'url secrète aux write-ups de notre choix. 

Prenons cet exemple :
```bash
echo -n "password" | openssl sha1
cb1dc474e185777dad218b7d60f2781723d8190b // Nom de write-up secret
```

imaginons que password soit le **mot de passe** secret du write-up que nous voulons protéger. Le nom du fichier en question à protéger devra alors être `cb1dc474e185777dad218b7d60f2781723d8190b.md`

On peut ainsi ajouter ce bouton d'ouverture à volonté. Il permet d'ouvrir une boite de dialogue directement dans nos write-up (par exemple pour que les write-up de niveau 2 donnent accès aux niveau 3).

Il suffit d'ajouter ce code dans le contenu de notre **write-up.mp**:

```html
{{< button label="Button" class="level-3" link="/" style="solid" >}}
```

Un clic sur ce bouton affichera donc un prompt dans lequel on peut entrer notre mot de passe (ou notre flag). 

Si le hash de ce mot de passe correspond, nous serons redirigé vers l'url du write-up secret (où `url = sha1(password)`). Dans le cas contraire, l'utilisateur recevra un message d'erreur. 

Enfin, pour masquer l'article (afin qu'il ne soit pas rajouté dans la liste des articles en clair), on rajoute la propriété `isSecret: true` dans les métadonnées que l'on retrouve dans l'entête d'un l'article.

Pensez également à mettre **draft** à **true** pour que le post n'apparaisse pas dans la liste sur la page `/blog`.

> Pour le moment, tous les write-ups secrets restent à la racine de `/blog`

Le **nom du dossier** contenant l'article (`.md`) et ses assets **définit son chemin dans l'url**.
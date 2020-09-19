---
title: PostgreSQL Notes
description: First experiment with PostgreSQL
date: 2020-08-14
---

{{< table-of-contents >}}

## Links

- https://postgresql.org
- https://nixos.org/nixos/manual#module-postgresql
- https://github.com/PostgresApp/PostgresApp/issues/313

## Installation

`/etc/nixos/configuration.nix`

```
services.postgresql.enable = true;
services.postgresql.package = pkgs.postgresql_12;
services.postgresql.dataDir = "/data/postgresql";
```

[NixOS – PostgreSQL]

[NixOS – PostgreSQL]: https://nixos.org/nixos/manual#module-postgresql

## Setup

```
sudo [--user -u] postgres createuser [--username -U] postgres [--superuser -s] taupiqueur
sudo [--user -u] postgres createdb taupiqueur
```

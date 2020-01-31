---
title: Password Management
description: One password to rule them all
date: 2019-03-27
---

In this post, I’ll show you the way I manage my passwords with the concept of _one unique master password_,
illustrated in the excellent [Yann Esposito’s Password Management].

{{< table-of-contents >}}

## Creating Passwords

### The Material

`encrypt`

``` sh
#!/bin/sh

shasum -a 512 | base64
```

`slice`

``` sh
#!/bin/sh

cut -c "$1" | head -n 1
```

`alnum`

``` sh
#!/bin/sh

tr -c -d [:alnum:]
```

`make-password`

``` sh
#!/bin/sh

name=$1
domain=$2
password=$3
length=${4:-10}

printf '%s\n' "$name@$domain:$password" | encrypt | slice "1-$length"
```

### Usage

```
make-password {name} {domain} {password} [length = 10]
```

**Example** – Create an account on [GitHub]:

``` sh
make-password alexherbo2 github.com my-unique-password
# ODUwMjJmMm
```

**Example** – Create an account on a site with restricted characters:

If your password is limited to alphanumeric characters, you can use `alnum`:

``` sh
make-password alexherbo2 example.com my-unique-password | alnum
# NWVhNWJkZT
```

## Managing Passwords

### The Material

`shard.yml`

``` yaml
name: tools
version: 0.1.0
license: Unlicense
targets:
  get-password:
    main: src/get-password.cr
  menu-password:
    main: src/menu-password.cr
```

`src/get-password.cr`

``` crystal
require "yaml"

CONFIG = File.join(
  ENV["XDG_CONFIG_HOME"],
  "passwords.yml"
)

alias Passwords = Hash(String, Array(String))

passwords = File.open(CONFIG) do |file|
  Passwords.from_yaml(file)
end

key = ARGV.first
puts passwords[key].last
```

`src/menu-password.cr`

``` crystal
require "yaml"

CONFIG = File.join(
  ENV["XDG_CONFIG_HOME"],
  "passwords.yml"
)

alias Passwords = Hash(String, Array(String))

passwords = File.open(CONFIG) do |file|
  Passwords.from_yaml(file)
end

case ARGV.size
when 0
  puts passwords.keys.join('\n')
when 1
  key = ARGV.first
  puts passwords[key].last
end
```

`Makefile`

``` makefile
build:
	shards build --release

clean:
	rm -Rf bin
```

`.gitignore`

```
bin
```

`make-password`

``` sh
password=${3:-$(get-password master)}
```

### Usage

Add your master password in `~/.config/passwords.yml`:

`~/.config/passwords.yml`

``` yaml
master:
- my-unique-password
```

Now you can generate new passwords without filling your master password.

**Example**

``` sh
make-password alexherbo2 github.com
# ODUwMjJmMm
```

Add it to your `~/.config/passwords.yml`:

`~/.config/passwords.yml`

``` yaml
alexherbo2@github.com:
- ODUwMjJmMm
```

You can now get it with:

``` sh
get-password alexherbo2@github.com
```

Or the menu command using [fzf]:

``` sh
get-password (menu-password | fzf)
```

[Yann Esposito’s Password Management]: https://yannesposito.com/Scratch/en/blog/Password-Management/
[GitHub]: https://github.com
[fzf]: https://github.com/junegunn/fzf

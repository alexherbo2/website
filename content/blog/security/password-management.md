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

shasum --algorithm 512 | base64
```

`slice`

``` sh
#!/bin/sh

cut --zero-terminated --characters $1
```

`alnum`

``` sh
#!/bin/sh

sed s/[^[:alnum:]]//g
```

`make-password`

``` sh
#!/bin/sh

name=$1
domain=$2
password=$3
length=${4:-10}

printf "$name@$domain:$password" | encrypt | slice 1-$length
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

`get-password`

``` ruby
#!/usr/bin/env ruby

require 'yaml'

data = YAML.load(File.read(File.join(ENV['XDG_CONFIG_HOME'], 'passwords.yml')))

key = ARGV.join(' ')

begin
  puts data[key].last
rescue
  exit 1
end
```

`menu-password`

``` ruby
#!/usr/bin/env ruby

require 'yaml'

data = YAML.load(File.read(File.join(ENV['XDG_CONFIG_HOME'], 'passwords.yml')))

key = ARGV.join(' ')

if not key.empty?
  puts data[key].last
else
  puts data.keys.join("\n")
end
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

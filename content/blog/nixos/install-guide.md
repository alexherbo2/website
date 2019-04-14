---
title: NixOS – Installation Guide
description: The steps I followed to install and configure NixOS
date: 2018-09-13
draft: true
---

## About

- Purely functional Linux distribution.
- Uses [Nix] package manager.

{{< table-of-contents >}}

## 1. [Obtaining NixOS]

[Get NixOS] and verify the integrity of the ISO.

``` sh
grep nixos-graphical-19.03.172138.5c52b25283a-x86_64-linux.iso nixos-graphical-19.03.172138.5c52b25283a-x86_64-linux.iso.sha256 | shasum [--algorithm -a] 256 [--check -c]
```

## 2. [Booting the system]

Write NixOS on your USB stick (be careful, it’s `/dev/sdb` in my case).

``` sh
dd if=nixos-graphical-19.03.172138.5c52b25283a-x86_64-linux.iso of=/dev/sdb
```

Boot NixOS then you’re ready for the next step.

## 3. [Partitioning and formatting]

Wipe the file system:

``` sh
wipefs [--all -a] /dev/sda
```

Create the partitions, formats and labels:

``` sh
gparted
```

You can use [GParted] or [gdisk], but I recommend GParted for discoverability.

1. Create a GUID table: _Device_ ❯ _Create Partition Table_ ❯ _GPT_
  - Select `/dev/sda`
  - Entire disk
2. Create the boot partition: _Partition_ ❯ _New_
  - Free space preceding (MiB): 1 (You cannot less; space assigned to GPT)
  - New size (MiB): 512
  - Free space following (MiB): Rest
  - Align to: MiB
  - Create as: Primary Partition
  - Partition name: EFI
  - File system: `fat32`
  - Label: EFI
3. Add the `boot` flag
  - Right-click on `/dev/sda1` to manage flags
  - Add the `boot` flag and enable `esp` (should be automatic with GPT)
4. Create the root partition: _Partition_ ❯ _New_
  - Free space preceding (MiB): 0
  - New size (MiB): Rest
  - Free space following (MiB): 0
  - Align to: MiB
  - Create as: Primary Partition
  - Partition name: NixOS
  - File system: `ext4`
  - Label: NixOS
5. Apply modifications

## 4. [Installing]

Mount the root and boot partitions:

``` sh
mkdir /mnt/nixos
mount /dev/disk/by-label/NixOS /mnt/nixos
mkdir /mnt/nixos/boot
mount /dev/disk/by-label/EFI /mnt/nixos/boot
```

Generate an initial configuration:

``` sh
nixos-generate-config --root /mnt/nixos
# /etc/nixos/configuration.nix
# /etc/nixos/hardware-configuration.nix
```

Do the installation:

``` sh
nixos-install --root /mnt/nixos
```

If everything went well:

``` sh
reboot
```

## 5. [Changing the Configuration]

The file `/etc/nixos/configuration.nix` contains the current configuration of your machine.
Whenever you’ve [changed something][Configuration] in that file, you should do `nixos-rebuild switch` to switch to the new configuration.

``` sh
nixos-rebuild switch
```

**Warning**: These commands must be executed as root, so you should either run them from a root shell or by prefixing them with `sudo [--login -i]`.

You can check my configuration [here][Personal Configuration].

### [Packages]

``` sh
nix search [package]
```

### [Options]

``` sh
man configuration.nix
```

## 6. [Upgrading NixOS]

When you first install NixOS, you’re automatically subscribed to the NixOS channel that corresponds to your installation source.
For instance, if you installed from a 19.03 ISO, you will be subscribed to the `nixos-19.03` channel.
To see which NixOS channel you’re subscribed to, run the following as root:

``` sh
nix-channel --list
# nixos https://nixos.org/channels/nixos-19.03
```

If you want to live on the bleeding edge:

``` sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

To upgrade NixOS:

``` sh
nixos-rebuild switch --upgrade
```

The command is equivalent to the more verbose:

``` sh
nix-channel --update
nixos-rebuild switch
```

## 7. [Cleaning the Nix Store]

``` sh
nix-collect-garbage [--delete-old -d]
```

## 8. [Package Management]

### [Customising Packages]

See also:

- [Overlays]
- [Modify packages via packageOverrides]

### [Adding Custom Packages]

## 9. Developing

### [Support for specific programming languages and frameworks]

### [I installed a library but my compiler is not finding it.  Why?]

Command-line:

``` sh
nix-shell [--packages -p] pkg-config rustc cargo
```

Using `default.nix` or `shell.nix`:

``` sh
with import <nixpkgs> {};

mkShell {
  buildInputs = [
    pkg-config
    rustc
    cargo
  ];
}
```

``` sh
nix-shell
```

[pkgs.mkShell] is a simplified version of `stdenv.mkDerivation`:

``` sh
with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "dev-environment";
  buildInputs = [
    pkg-config
    rustc
    cargo
  ];
}
```

You can see its definition on [GitHub][mkshell.nix].

### [I’m working on a new package, how can I build it without adding it to nixpkgs?]

Assuming your package name is `default.nix`:

``` sh
nix build '(
  with import <nixpkgs> {};
  callPackage ./default.nix {}
)'
# result → /nix/store/{hash}-{name}-{version}
```

## 10. [FAQ]

[NixOS]: https://nixos.org
[Get NixOS]: https://nixos.org/nixos/download.html
[Packages]: https://nixos.org/nixos/packages.html
[Options]: https://nixos.org/nixos/options.html
[Nix]: https://nixos.org/nix/
[Obtaining NixOS]: https://nixos.org/nixos/manual#sec-obtaining
[Booting the system]: https://nixos.org/nixos/manual#sec-installation-booting
[Partitioning and formatting]: https://nixos.org/nixos/manual#sec-installation-partitioning
[GParted]: https://gparted.org
[gdisk]: https://rodsbooks.com/gdisk/
[Installing]: https://nixos.org/nixos/manual#sec-installation-installing
[Changing the Configuration]: https://nixos.org/nixos/manual#sec-changing-config
[Configuration]: https://nixos.org/nixos/manual#ch-configuration
[Personal Configuration]: https://github.com/alexherbo2/configuration/blob/master/etc/nixos/configuration.nix
[Upgrading NixOS]: https://nixos.org/nixos/manual#sec-upgrading
[Cleaning the Nix Store]: https://nixos.org/nixos/manual#sec-nix-gc
[Package Management]: https://nixos.org/nixos/manual#sec-package-management
[Customising Packages]: https://nixos.org/nixos/manual#sec-customising-packages
[Overlays]: https://nixos.org/nixpkgs/manual#chap-overlays
[Modify packages via packageOverrides]: https://nixos.org/nixpkgs/manual#sec-modify-via-packageOverrides
[Adding Custom Packages]: https://nixos.org/nixos/manual#sec-custom-packages
[Support for specific programming languages and frameworks]: https://nixos.org/nixpkgs/manual#chap-language-support
[FAQ]: https://nixos.wiki/wiki/FAQ
[I installed a library but my compiler is not finding it.  Why?]: https://nixos.wiki/wiki/FAQ#I_installed_a_library_but_my_compiler_is_not_finding_it._Why.3F
[I’m working on a new package, how can I build it without adding it to nixpkgs?]: https://nixos.wiki/wiki/FAQ#I.27m_working_on_a_new_package.2C_how_can_I_build_it_without_adding_it_to_nixpkgs.3F
[pkgs.mkShell]: https://nixos.org/nixpkgs/manual#sec-pkgs-mkShell
[mkshell.nix]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/mkshell/default.nix

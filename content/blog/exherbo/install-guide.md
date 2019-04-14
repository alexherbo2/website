---
title: Exherbo – Installation Guide
description: The steps I followed to install and configure Exherbo
date: 2013-03-14
context: TupperVim mawww Kakoune
---

## About

- Source-based Linux distribution.
- Decentralized development.
  - Writing your own packages, adding and modifying those from others is easy.
- For developers.
  - Developing on a specific version of a program is easy.
- Uses [Paludis] package manager.

{{< table-of-contents >}}

## 1. Read the documentation

- Read the official documentation and [install guide][Installation Guide] on [Exherbo] and [Paludis].
- Join [#exherbo] for help.

## 2. Boot a live system

[Get Ubuntu][] (or any distribution if you are not on Linux already) and verify the integrity of the ISO.

``` sh
curl [--remote-name -O] http://releases.ubuntu.com/disco/ubuntu-19.04-desktop-amd64.iso
curl --remote-name http://releases.ubuntu.com/disco/SHA256SUMS
```

Verify the integrity of the ISO:

``` sh
grep ubuntu-19.04-desktop-amd64.iso SHA256SUMS | shasum [--algorithm -a] 256 [--check -c]
```

Then write Ubuntu on your USB stick (be careful, it’s `/dev/sdb` in my case).

``` sh
dd if=ubuntu-19.04-desktop-amd64.iso of=/dev/sdb
```

Boot Ubuntu then you’re ready for the next step.

## 3. Prepare the hard disk

Wipe the file system:

``` sh
wipefs [--all -a] /dev/sda
```

Create the partitions:

``` sh
fdisk /dev/sda
# Boot (EFI):
# Press 'n' for new partition
# – Partition type: 'p' for primary – should be default
# – Partition number: 1 – should be default
# – First sector: Use default
# – Last sector: +512M
# Press 't' to change partition type
# – Partition number: 1 – should be default
# – Partition type: 1 for EFI System
# Root:
# Press 'n' for new partition
# – Partition type: 'p' for primary – should be default
# – Partition number: 2 – should be default
# – First sector: Use default
# – Last sector: Use default
# Press 'w' to save and exit
```

Format and label the file systems for each partition:

``` sh
mkfs.fat -F 32 /dev/sda1 -n EFI # Boot (EFI)
fatlabel /dev/sda1 EFI # Optional, to label a FAT disk after its creation
mkfs.ext4 /dev/sda2 -L Exherbo # Root
e2label /dev/sda2 Exherbo # Optional, to label an ext disk after its creation
```

Mount the root partition and navigate to it:

``` sh
mount /dev/disk/by-label/Exherbo /mnt/exherbo
cd /mnt/exherbo
```

Get the latest archive of Exherbo from [Stages] and verify the consistence of the file:

``` sh
curl --remote-name http://dev.exherbo.org/stages/exherbo-x86_64-pc-linux-gnu-current.tar.xz
curl --remote-name http://dev.exherbo.org/stages/sha256sum
grep exherbo-x86_64-pc-linux-gnu-current.tar.xz sha256sum | shasum --algorithm 256 --check
```

Extract the stage:

``` sh
unxz [--to-stdout -c] exherbo-x86_64-pc-linux-gnu-current.tar.xz |
tar [--extract -x] [--preserve-permissions -p] [--preserve-order -s] [--file -f] -
```

Update `/mnt/exherbo/etc/fstab`:

`/mnt/exherbo/etc/fstab`

```
# FILE SYSTEM MOUNT POINT TYPE OPTIONS DUMP PASS
/dev/disk/by-label/Exherbo / ext4 defaults 0 0
/dev/disk/by-label/EFI /boot vfat defaults 0 0
```

## 4. Chroot into the system

Make sure the network can resolve DNS:

`/mnt/exherbo/etc/resolv.conf`

```
# Google DNS
# https://developers.google.com/speed/public-dns/docs/using
nameserver 8.8.8.8
nameserver 8.8.4.4
```

Spawn Exherbo namespace container with [`systemd-nspawn`]:

``` sh
systemd-nspawn
```

Or mount everything for the chroot manually:

``` sh
mount [--options -o] rbind /dev /mnt/exhero/dev
mount --options bind /sys /mnt/exherbo/sys
mount [--types -t] proc none /mnt/exherbo/proc
mount /dev/disk/by-label/EFI /mnt/exherbo/boot
env [--ignore-environment -i] TERM=$TERM SHELL=/bin/bash HOME=$HOME $(which chroot) /mnt/exherbo /bin/bash
```

Then when in Exherbo:

``` sh
source /etc/profile
PS1="(Exherbo) $PS1"
```

## 5. Update the install

Make sure Paludis is configured correctly:

``` sh
vi /etc/paludis/bashrc /etc/paludis/*.conf
```

Sync all the trees – now it is safe to sync:

``` sh
cave sync
```

You may want to re-install the packages included in the stage:

``` sh
cave resolve [--execute -x] world
```

## 6. Make it bootable

Clone the [stable kernel][Linux/Kernel] on [Linux] and navigate to it:

``` sh
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux /kernel
cd /kernel
```

Switch to the latest stable kernel:

``` sh
git checkout tags/v5.0.7 # 5.0.7 in my case
```

Configure and install the kernel:

``` sh
make nconfig
make # Compile kernel to arch/x86/boot/bzImage
make modules_install
```

Make sure to re-install [`systemd`] in order to create a valid [`machine-id`]:

``` sh
cave resolve --execute [--preserve-world -1] --skip-phase test sys-apps/systemd
```

Install [`systemd-boot`]:

``` sh
bootctl install
```

You have to install [`sys-apps/systemd`] with the `efi` option enabled to use this command.

Open `/etc/paludis/options.conf` and add:

`/etc/paludis/options.conf`

```
sys-apps/systemd efi
```

Copy the kernel you just installed into the appropriate directory:

``` sh
kernel-install add 5.0.7 /boot/vmlinuz-5.0.7
```

To remove old kernel versions:

``` sh
kernel-install remove {kernel-version}
```

Configure your hostname for `systemd`:

`/etc/hostname`

```
othala
```

Make sure your hostname is mapped to `localhost` in `/etc/hosts`,
otherwise some packages test suites will fail because of network sandboxing.

`/etc/hosts`

```
127.0.0.1 localhost othala
::1 localhost othala
```

If you need additional kernel support e.g. for an Intel wireless card,
install the Linux firmware files.

``` sh
cave resolve --execute firmware/linux-firmware
```

Set root password:

``` sh
passwd
```

Configure locales:

``` sh
localdef [--inputfile -i] en_US [--charmap -f] UTF-8 en_US.UTF-8
```

`/etc/locale.conf`

``` sh
LANG=en_US.UTF-8
```

Set the time-zone:

``` sh
ln [--symbolic -s] /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

Sync hardware clock 'aka BIOS' with the current system time.

```
hwclock [--systohc -w] [--utc -u]
```

Reboot:

``` sh
reboot
```

## 7. Post-installation tasks

Remove the stage tarball:

``` sh
rm /exherbo-x86_64-pc-linux-gnu-current.tar.xz
```

The installation images (stages) contain additional tools which are useful
for the installation process but are not part of the system nor world sets
but the stages set.

You can identify the additional packages using [`cave show`]:

``` sh
cave show stages
```

If you wish to remove them, you can simply use [`cave purge`]:

``` sh
cave purge
```

Alternatively, you can add packages you wish to retain to the world set by using
the [`update-world`][`cave update-world`] command.  As an example, the following
adds [`sys-devel/gdb`] to the world set:

``` sh
cave update-world sys-devel/gdb
```

If you want to add all packages of the stages to the world set:

``` sh
cave update-world [--set -s] stages
```

Add a new user for daily use:

``` sh
useradd [--create-home -m] [--groups -G] adm,disk,wheel,cdrom,audio,video,usb,users alex
```

To add groups:

``` sh
usermod [--append -a] [--groups -G] {groups} alex
```

Set user password:

``` sh
passwd alex
```

Install [`app-admin/sudo`]:

``` sh
cave resolve --execute app-admin/sudo
```

Allow members of `wheel` to execute `sudo` with no password:

`/etc/sudoers`

```
%wheel ALL=(ALL) NOPASSWD: ALL
```

## 8. Configuring your desktop

### Power keys

By default, closing the lid suspends your computer and pressing the power key
powers off it.  Just fix that, by opening [`logind`] configuration:

`/etc/systemd/logind.conf`

```
[Login]
HandleLidSwitch=ignore
HandlePowerKey=hibernate
HandleSuspendKey=suspend
HandleHibernateKey=hibernate
```

Take your changes into account:

``` sh
systemctl restart systemd-logind
```

### Editor

Install [Kakoune]:

``` sh
cave resolve --execute app-editors/kakoune
```

You will be tell Kakoune is [masked by unavailable], which means the package
comes from an [unavailable-unofficial][Summer] repository.

Let’s add the repository:

``` sh
cave resolve --execute repository/mawww
```

The command will install [`mawww`][`repository/mawww`] in `/etc/paludis/repositories/mawww.conf`
and populate the contents with `/etc/paludis/repository.template`.

### Shell

At the time being, there is no [Elvish] package supported officially.

To create your own, see [Exheres for Smarties] and the next section
[Creating your own packages].

Once `app-shells/elvish` has been added:

``` sh
cave resolve --execute app-shells/elvish
```

You can also change your default shell, but it may be risky to log in a custom shell.

If you want it, first add the full path to Elvish to `/etc/shells`:

`/etc/shells`

```
/bin/elvish
```

Then change your shell with:

``` sh
chsh [--shell -s] /bin/elvish
```

### Networking

Install network tools:

``` sh
cave resolve --execute sys-apps/iproute2
cave resolve --execute net-wireless/wireless_tools
```

Install [NetworkManager] and its applet:

``` sh
cave resolve --execute net-apps/NetworkManager
cave resolve --execute gnome-desktop/gnome-keyring
cave resolve --execute gnome-desktop/network-manager-applet
```

### Sound

Install [ALSA]:

``` sh
cave resolve --execute sys-sound/alsa-utils
```

Install [PulseAudio] and its applet:

``` sh
cave resolve --execute media-sound/pulseaudio
cave resolve --execute media-sound/pulseaudio-applet
```

Install the graphical volume control:

``` sh
cave resolve --execute media-sound/pavucontrol
```

Enable PulseAudio:

``` sh
systemctl --user enable --now pulseaudio
```

### Window manager

Install [X]:

``` sh
cave resolve --execute x11-server/xorg-server
```

If you need additional [`x11-drivers`] e.g. Intel:

``` sh
cave search x11-drivers/xf86-video
# …
# x11-drivers/xf86-video-intel
# …
cave resolve --execute x11-drivers/xf86-video-intel
```

Install [i3]:

``` sh
cave resolve --execute x11-wm/i3
```

For other [`x11-apps`] or [`x11-utils`]:

``` sh
cave search x11-apps/{package-name}
cave search x11-utils/{package-name}
```

### Fonts

Install DejaVu fonts:

``` sh
cave resolve --execute fonts/dejavu
```

Disable bitmap fonts:

``` sh
ln --symbolic /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
```

### Browsing

Install [Chromium]:

```
cave resolve --execute net-www/chromium-stable
```

Set Chromium as the default browser:

`~/.config/mimeapps.list`

```
[Default Applications]
text/html=chromium-browser.desktop
x-scheme-handler/http=chromium-browser.desktop
x-scheme-handler/https=chromium-browser.desktop
```

If you wish a test, try:

```
xdg-open https://exherbo.org
```

## 9. Useful commands

### Uninstall a package

``` sh
cave resolve !{package-name}
```

You can also edit your `/etc/paludis/world` and `cave resolve world` to update.

### Updating the system

``` sh
cave resolve world
  [--complete -c]
  [--preserve-world -1]
  [--continue-on-failure -C] [if-satisfied s]
  [--keep -k] [if-same-metadata m]
  [--keep-targets -K] [if-same-metadata m]
```

Taken from [Clément Delafargue – My everyday Exherbo commands].

### Show the dependencies of a package

``` sh
cave show [--complex-keys -c] {package-name}
```

### Print the contents of a package

``` sh
cave print-id-contents {package-name}
```

## 10. Creating your own packages

- Read the official documentation on [Exheres for Smarties].
- Take example on existing repositories e.g. [mawww][`repository/mawww`],
  [Sardem FF7][`repository/sardemff7`] or [mine][`repository/alexherbo2`].

To start, create a new repository to hold the package’s files.

``` sh
git init exheres
cd exheres
```

Create the following files:

`profiles/repo_name`

```
alexherbo2
```

`metadata/about.conf`

```
homepage = https://github.com/alexherbo2/exheres
summary = alexherbo2’s supplemental repository
description = alexherbo2’s tasty exhereses
owner = alexherbo2 <alexherbo2@gmail.com>
status = third-party
```

`metadata/layout.conf`

```
layout = exheres
eapi_when_unknown = exheres-0
eapi_when_unspecified = exheres-0
profile_eapi_when_unspecified = exheres-0
masters = arbor
```

Create your first package.  As an example, we’ll create `app-shells/elvish` and
use the [Go][`go.exlib`] [exlib][Exlibs].

`packages/app-shells/elvish/elvish-scm.exheres-0`

```
SUMMARY='Friendly interactive shell and expressive programming language'
HOMEPAGE='https://elv.sh'

require go [ project=github.com/elves/elvish ]

LICENSES='BSD-2'
PLATFORMS='~amd64 ~x86'
```

`metadata/categories.conf`

```
app-shells
```

`metadata/repository_mask.conf`

```
app-shells/elvish[~scm] [[
  author = [ alexherbo2 <alexherbo2@gmail.com> ]
  date = [ 04 Apr 2019 ]
  token = scm
  description = [ Mask -scm version ]
]]
```

Update your Paludis configuration to include your repository:

`/etc/paludis/repositories/alexherbo2.conf`

```
format = e
location = /var/db/paludis/repositories/alexherbo2
sync = git+https://github.com/alexherbo2/exheres
```

Finally, sync the trees:

``` sh
cave sync
```

## 11. Share your configuration

Because it’s always worth to see how others configure things e.g.
[Keruspe][Keruspe’s configuration] or [me][alexherbo2’s configuration].

## 12. Contributing

- Read [Workflow].

Repositories are configured as normal, with their `sync` set to point to the
usual remote location.  In addition, for any repository you are going to work
on, you use a sync suffix to specify a local path too.  For example:

`/etc/paludis/repositories/arbor.conf`

```
sync = git+https://git.exherbo.org/git/arbor.git local: git+file:///home/alex/exherbo/exheres/arbor
```

Where `~/exherbo/exheres/arbor` is a personal copy of the repository.

Normally, when you sync, you’ll be syncing against upstream.  But when you want
to do some work:

Clone the repository:

``` sh
git clone git://git.exherbo.org/arbor.git ~/exherbo/exheres/arbor
```

Work on and commit your changes.

Sync the local repository rather than the upstream:

```
cave sync [--source -s] local [--revision -r] {commit-id} arbor
```

Test your changes.

Push your changes to [GitLab][Exherbo – GitLab].
See the [documentation][Exherbo – GitLab (Documentation)] for more information.

[Create an account][Exherbo – GitLab – Sign in] on the GitLab instance.

Add your [SSH key][Exherbo – GitLab – SSH Keys] for easier pushing via SSH instead of HTTPS.

Fork [`arbor`][`arbor` (GitLab)].

Clone your fork of it:

``` sh
git clone git@gitlab.exherbo.org:alexherbo2/arbor.git
```

If you already cloned the repo you can add your fork as remote:

``` sh
git remote set-url origin git@gitlab.exherbo.org:alexherbo2/arbor.git
git remote add upstream https://gitlab.exherbo.org/exherbo/arbor.git
```

Push your changes.

Create a new [pull request][`arbor` (Pulls)].

Go back to syncing without the suffix.

[Creating your own packages]: #10-creating-your-own-packages
[Clément Delafargue – My everyday Exherbo commands]: http://blog.clement.delafargue.name/posts/2012-10-26-my-everyday-exherbo-commands.html
[Stages]: http://dev.exherbo.org/stages/
[Get Ubuntu]: http://releases.ubuntu.com
[ALSA]: https://alsa-project.org
[Chromium]: https://chromium.org
[Elvish]: https://elv.sh
[Exheres for Smarties]: https://exherbo.com/docs/eapi/exheres-for-smarties.html
[Exlibs]: https://exherbo.org/docs/eapi/exheres-for-smarties.html#exlibs
[Masked by unavailable]: https://exherbo.org/docs/faq.html#masked_by_unavailable
[Exherbo – GitLab (Documentation)]: https://exherbo.org/docs/gitlab.html
[Installation Guide]: https://exherbo.org/docs/install-guide.html
[Workflow]: https://exherbo.org/docs/workflow.html
[Exherbo]: https://exherbo.org
[`machine-id`]: https://freedesktop.org/software/systemd/man/machine-id.html
[`systemd-nspawn`]: https://freedesktop.org/software/systemd/man/systemd-nspawn.html
[PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio/
[`logind`]: https://freedesktop.org/wiki/Software/systemd/logind/
[`systemd-boot`]: https://freedesktop.org/wiki/Software/systemd/systemd-boot/
[`systemd`]: https://freedesktop.org/wiki/Software/systemd/
[`go.exlib`]: https://git.exherbo.org/arbor.git/tree/exlibs/go.exlib
[`app-admin/sudo`]: https://git.exherbo.org/summer/packages/app-admin/sudo/
[`sys-apps/systemd`]: https://git.exherbo.org/summer/packages/sys-apps/systemd/
[`sys-devel/gdb`]: https://git.exherbo.org/summer/packages/sys-devel/gdb/
[`x11-apps`]: https://git.exherbo.org/summer/packages/x11-apps/
[`x11-drivers`]: https://git.exherbo.org/summer/packages/x11-drivers/
[`x11-utils`]: https://git.exherbo.org/summer/packages/x11-utils/
[Summer]: https://git.exherbo.org/summer/
[`repository/alexherbo2`]: https://github.com/alexherbo2/exheres
[alexherbo2’s configuration]: https://github.com/alexherbo2/paludis
[Keruspe’s configuration]: https://github.com/Keruspe/paludis-config
[`repository/mawww`]: https://github.com/mawww/mawww
[`repository/sardemff7`]: https://github.com/sardemff7/sardemff7-exheres
[Linux/Kernel]: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
[`arbor` (GitLab)]: https://gitlab.exherbo.org/exherbo/arbor
[`arbor` (Pulls)]: https://gitlab.exherbo.org/exherbo/arbor/merge_requests
[Exherbo – GitLab]: https://gitlab.exherbo.org
[Exherbo – GitLab – SSH Keys]: https://gitlab.exherbo.org/profile/keys
[Exherbo – GitLab – Sign in]: https://gitlab.exherbo.org/users/sign_in
[i3]: https://i3wm.org
[Kakoune]: https://kakoune.org
[Linux]: https://kernel.org
[`cave purge`]: https://paludis.exherbo.org/clients/cave-purge.html
[`cave show`]: https://paludis.exherbo.org/clients/cave-show.html
[`cave update-world`]: https://paludis.exherbo.org/clients/cave-update-world.html
[Paludis]: https://paludis.exherbo.org
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[X]: https://x.org
[#exherbo]: irc://chat.freenode.net/exherbo

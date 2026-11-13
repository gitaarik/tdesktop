#!/bin/bash
# Build the package inside an archlinux:base-devel container, as GitHub's
# workflow does (see arch-package.yml). Run as root from the arch/ directory;
# the package ends up next to the PKGBUILD.
set -euo pipefail

pacman -Syu --noconfirm --needed base-devel git sudo

# No debug package and no LTO: the runner has 4 cores, 16 GB of RAM and limited
# disk, and neither changes what the package does.
sed -i -E 's/^(OPTIONS=.*[ (])debug/\1!debug/; s/^(OPTIONS=.*[ (])lto/\1!lto/' /etc/makepkg.conf
grep '^OPTIONS=' /etc/makepkg.conf

# makepkg refuses to run as root.
useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chown -R builder .
sudo -u builder makepkg --syncdeps --noconfirm

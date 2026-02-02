#!/usr/bin/env bash
set -euo pipefail

PACMAN_FLAGS=(--noconfirm --needed)

die() { printf 'fatal: %s\n' "$*" >&2; exit 1; }

source /root/install.env 2>/dev/null || true

read -r -p "Hostname: " HOST
[[ -n "$HOST" ]] || die "empty hostname"

read -r -p "Username: " USERNAME
[[ -n "$USERNAME" ]] || die "empty username"

# Time, locale
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc

sed -i 's/^#\(en_AU.UTF-8 UTF-8\)$/\1/' /etc/locale.gen
locale-gen
cat > /etc/locale.conf <<EOF
LANG=en_AU.UTF-8
EOF

cat > /etc/hostname <<EOF
$HOST
EOF

cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOF

# Core packages: boot tooling, compositor stack, sound, polkit, portals
pacman -S "${PACMAN_FLAGS[@]}" \
  efibootmgr \
  base-devel git \
  seatd \
  polkit polkit-gnome \
  pipewire wireplumber pipewire-pulse \
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome \
  gnome-keyring \
  niri \
  greetd greetd-tuigreet

# User
useradd -m -G wheel,seat "$USERNAME"
passwd "$USERNAME"
passwd

install -d -m 0750 /etc/sudoers.d
cat > /etc/sudoers.d/10-wheel <<'EOF'
%wheel ALL=(ALL:ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/10-wheel

# Prefer iwd as NM backend (keeps the wireless stack tighter than legacy tools)
install -d /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/wifi_backend.conf <<'EOF'
[device]
wifi.backend=iwd
EOF

# systemd-boot
bootctl install

ROOT_DEV="$(findmnt -n -o SOURCE /)"
ROOT_UUID="$(blkid -s UUID -o value "$ROOT_DEV")"

UCODE_LINE=""
if [[ -f /boot/intel-ucode.img ]]; then UCODE_LINE="initrd  /intel-ucode.img"; fi
if [[ -f /boot/amd-ucode.img ]]; then   UCODE_LINE="initrd  /amd-ucode.img";   fi

install -d /boot/loader/entries
cat > /boot/loader/loader.conf <<'EOF'
default  arch
timeout  1
editor   no
EOF

cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
$UCODE_LINE
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOF

cat > /boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
$UCODE_LINE
initrd  /initramfs-linux-fallback.img
options root=UUID=$ROOT_UUID rw
EOF

mkinitcpio -P

# greetd + tuigreet -> niri-session
# greetd is documented on ArchWiki, including the config.toml layout. :contentReference[oaicite:7]{index=7}
install -d /etc/greetd
cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd niri-session"
user = "greeter"
EOF

systemctl enable NetworkManager iwd seatd greetd

#!/usr/bin/env bash
set -euo pipefail

# Optional: set SWAP_GIB=8 for a swap partition. Leave at 0 for no swap partition.
SWAP_GIB="${SWAP_GIB:-0}"

die() { printf 'fatal: %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "run as root"
[[ -d /sys/firmware/efi/efivars ]] || die "booted in legacy mode; need UEFI"

command -v sgdisk >/dev/null 2>&1 || die "missing sgdisk (package: gptfdisk)"
command -v mkfs.fat >/dev/null 2>&1 || die "missing mkfs.fat (package: dosfstools)"

printf 'Disks:\n'
lsblk -dpno NAME,SIZE,MODEL | sed 's/^/  /'

read -r -p "Target disk (example: /dev/nvme0n1 or /dev/sda): " DISK
[[ -b "$DISK" ]] || die "not a block device: $DISK"

printf '\nAbout to ERASE: %s\n' "$DISK"
read -r -p "Type WIPE to proceed: " CONFIRM
[[ "$CONFIRM" == "WIPE" ]] || die "aborted"

# Erase partition table and signatures
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"
sgdisk -o "$DISK"

# Partition: ESP (1 GiB) + optional swap + root (rest)
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "$DISK"

if [[ "$SWAP_GIB" != "0" ]]; then
  sgdisk -n 2:0:+"${SWAP_GIB}"G -t 2:8200 -c 2:SWAP "$DISK"
  sgdisk -n 3:0:0               -t 3:8300 -c 3:ROOT "$DISK"
else
  sgdisk -n 2:0:0               -t 2:8300 -c 2:ROOT "$DISK"
fi

partprobe "$DISK"
sleep 1

# NVMe/mmcblk devices need a 'p' before the partition number.
PFX=""
[[ "$DISK" =~ [0-9]$ ]] && PFX="p"

ESP="${DISK}${PFX}1"
if [[ "$SWAP_GIB" != "0" ]]; then
  SWAP="${DISK}${PFX}2"
  ROOT="${DISK}${PFX}3"
else
  ROOT="${DISK}${PFX}2"
fi

mkfs.fat -F 32 -n EFI "$ESP"
if [[ "$SWAP_GIB" != "0" ]]; then
  mkswap -L swap "$SWAP"
  swapon "$SWAP"
fi
mkfs.ext4 -F -L arch "$ROOT"

mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$ESP" /mnt/boot

# Microcode autodetect (your old script hard-coded amd-ucode)
UCODE=""
if grep -qm1 'GenuineIntel' /proc/cpuinfo; then UCODE="intel-ucode"; fi
if grep -qm1 'AuthenticAMD' /proc/cpuinfo; then UCODE="amd-ucode"; fi

pacstrap /mnt \
  base linux linux-firmware \
  sudo vim \
  networkmanager iwd \
  man-db man-pages \
  "$UCODE"

genfstab -U /mnt > /mnt/etc/fstab

# Drop an env file so config.sh can infer devices if you want it.
cat > /mnt/root/install.env <<EOF
DISK=$DISK
ESP=$ESP
ROOT=$ROOT
SWAP_GIB=$SWAP_GIB
EOF

# If config.sh is present alongside this script, copy it into the new system and run it.
if [[ -f ./config.sh ]]; then
  install -m 0755 ./config.sh /mnt/root/config.sh
  arch-chroot /mnt /root/config.sh
else
  printf '\nNow chroot manually:\n  arch-chroot /mnt\n'
fi

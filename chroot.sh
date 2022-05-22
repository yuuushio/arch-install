#!/bin/bash

read -r -p "Enter drive name (example sda) " drive

mkfs.vfat /dev/${drive}1

mkswap /dev/${drive}2
swapon /dev/${drive}2

mkfs.ext4 /dev/${drive}3

mount /dev/${drive}3 /mnt

mkdir -p /mnt/efi
mount /dev/${drive}1 /mnt/efi

pacstrap /mnt base base-devel linux linux-firmware vim man sudo amd-ucode

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab
sleep 1
arch-chroot /mnt

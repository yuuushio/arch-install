#!/bin/bash

read -r -p "Enter drive name (exapmle sda) " drive

yes | mkfs.vfat /dev/${drive}1

yes | mkswap /dev/${drive}2
yes | swapon /dev/${drive}2

yes | mkfs.ext4 /dev/${drive}3

mount /dev/${drive}3 /mnt

mkdir -p /mnt/efi
mount /dev/${drive}1 /mnt/efi

pacstrap /mnt base base-devel linux linux-firmware vim nano man sudo amd-ucode

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab
sleep 3
arch-chroot /mnt

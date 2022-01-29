#!/bin/bash

ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc

echo "en_AU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=en_AU.UTF-8" >> /etc/locale.conf

echo "ArchLite" >> /etc/hostname

echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ArchLite.localdomain ArchLite" >> /etc/hosts

pacman -S --no-confirm grub efibootmgr dosfstools mtools os-prober networkmanager network-manager-applet wireless_tools

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

echo "---Create Root Password & New User---"


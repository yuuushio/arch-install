#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay;makepkg -si --noconfirm;cd;rm -rf yay

sudo pacman -S --noconfirm xorg ttf-dejavu git polkit-gnome lightdm lightdm-gtk-greeter

sudo pacman -S --noconfirm arandr dmenu bash-completion bluez bluez-utils cups discord dunst ffmpegthumbnailer firefox firewalld gcolor3 gedit gzip hplip jupyter-notebook jupyterlab linux-headers lxappearance maim moreutils nautilus neofetch nfs-utils nitrogen nodejs npm ntfs-3g pamixer pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-media-session pipewire-pulse polkit-gnome pulsemixer python-pip qbittorrent redshift rofi sqlitebrowser sxiv texlive-most thunar vlc xclip zathura zathura-pdf-mupdf zsh

cd
repos=( "st" )
for repo in ${repos[@]}
do
    git clone git://git.suckless.org/$repo
    cd $repo;make;sudo make install;cd ..
done


git clone https://github.com/yuuushio/dwm.git
cd dwm;make;sudo make install;cd ..

git clone https://github.com/yuuushio/dwmblocks.git
cd dwmblocks;make;sudo make install;cd ..

# XSessions and dwm.desktop
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi

cd /usr/share/xsessions
sudo touch dwm.desktop
sudo chown $USER dwm.desktop
sudo cat > dwm.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=dwm
Exec=dwm
Icon=dwm
Type=XSession
EOF

systemctl enable lightdm
systemctl enable bluetooth

#sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
#sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
#yay -S downgrade otf-symbola nerd-fonts-complete typora-free lf-git timeshift jre ttf-ms-fonts virtualbox-ext-oracle visual-studio-code-bin ttf-mac-fonts libxft-bgra neovim-nightly-bin picom-jonaburg-git jdk powerline-fonts-git

echo "---Configure LightDM; Restart PC---"


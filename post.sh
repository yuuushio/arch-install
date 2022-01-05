#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay;makepkg -si -noconfirm;cd;rm -r yay

sudo pacman -S --noconfirm xorg ttf-dejavu git polkit-gnome lightdm lightdm-gtk-greeter

sudo pacman -S --noconfirm arandr bash-completion bluez bluez-utils cups discord dunst ffmpegthumbnailer firefox firewalld gcolor3 gedit gzip hplip jupyter-notebook jupyterlab linux-headers lxappearance maim moreutils nautilus neofetch nfs-utils nitrogen nodejs npm ntfs-3g pamixer pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-media-session pipewire-pulse polkit-gnome pulsemixer python-pip qbittorrent redshift rofi sqlitebrowser sxiv texlive-most thunar vlc xclip zathura zathura-pdf-mupdf zsh

cd
repos=( "dmenu" "st" "slock" )
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

cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=~/.dwm/autostart.sj
Icon=dwm
Type=XSession
EOF
sudo cp ./temp /usr/share/xsessions/dwm.desktop;rm ./temp

systemctl enable lightdm
systemctl enable bluetooth

yay -S downgrade otf-symbola nerd-fonts-complete typora-free lf-git timeshift jre ttf-ms-fonts virtualbox-ext-oracle visual-studio-code-bin ttf-mac-fonts libxft-bgra neovim-nightly-bin picom-jonaburg-git jdk powerline-fonts-git

echo "---Configure LightDM; Restart PC---"


#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay;makepkg -si;cd;rm -rf yay

sudo pacman -S xorg ttf-dejavu git polkit-gnome

sudo pacman -S arandr dmenu bluez bluez-utils cups \
dunst ffmpegthumbnailer gcolor3 gzip hplip \
linux-headers lxappearance-gtk3 maim moreutils nfs-utils \
ntfs-3g pamixer pavucontrol pipewire pipewire-alsa pipewire-jack \
pipewire-pulse pulsemixer python-pip qbittorrent \
redshift rofi sxiv texlive-most thunar xclip zathura zathura-pdf-mupdf \
zsh tmux texstudio

yay -S neovim-nightly-bin picom-jonaburg-git ly brave-bin

cd
# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install typewritten theme
git clone https://github.com/reobin/typewritten.git $ZSH_CUSTOM/themes/typewritten
ln -s "$ZSH_CUSTOM/themes/typewritten/typewritten.zsh-theme" "$ZSH_CUSTOM/themes/typewritten.zsh-theme"
ln -s "$ZSH_CUSTOM/themes/typewritten/async.zsh" "$ZSH_CUSTOM/themes/async"


cd

# -- install dots/configs
git clone https://github.com/yuuushio/dots.git;cd dots

mv dwmblocks ~/.config/
# mv -f icons/default ~/.icons/default # error cause .icons file doesnt exist yet
mv -f scripts/* ~/.dwm/
mv st ~/.config/
mv -f typewritten.zsh ~/.oh-my-zsh/custom/themes/typewritten/typewritten.zsh
mv -f picom.conf ~/.config/picom.conf
mv -f nvim ~/.config/
mv .zshrc ~/.zshrc
sudo mv bluetooth/main.conf /etc/bluetooth/main.conf
sudo mv pipewire.conf /usr/share/pipewire/pipewire.conf
# -----------------------

cd

rm -rf dots

#repos=( "st" )
#for repo in ${repos[@]}
#do
#    git clone git://git.suckless.org/$repo
#    cd $repo;make;sudo make install;cd ..
#done

git clone https://github.com/yuuushio/dwm.git
cd dwm;make;sudo make install;cd

cd ~/.config/st;make;sudo make clean install;cd
cd ~/.config/dwmblocks;make;sudo make clean install;cd


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
Exec=~/.dwm/autostart.sh
Icon=dwm
Type=XSession
EOF

systemctl enable ly
systemctl enable bluetooth
systemctl --user --now enable wireplumber

#sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
#sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
#yay -S downgrade otf-symbola nerd-fonts-complete typora-free lf-git timeshift jre ttf-ms-fonts virtualbox-ext-oracle visual-studio-code-bin ttf-mac-fonts libxft-bgra jdk powerline-fonts-git

echo "---Restart PC---"


#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay;makepkg -si;cd;rm -rf yay

sudo pacman -Syu

sudo pacman -S xorg ttf-dejavu git polkit-gnome

sudo pacman -S arandr dmenu bluez bluez-utils cups \
dunst ffmpegthumbnailer gcolor3 gzip hplip \
linux-headers lxappearance-gtk3 maim moreutils nfs-utils \
ntfs-3g pamixer pavucontrol pipewire wireplumber pipewire-alsa pipewire-jack \
pipewire-pulse pulsemixer python-pip qbittorrent \
redshift rofi sxiv xclip zathura zathura-pdf-mupdf \
zsh tmux texstudio texlive nautilus nemo\
libmpdclient slock feh kitty

#repos=( "st" "dwm" )
#for repo in ${repos[@]}
#do
#    git clone git://git.suckless.org/$repo
#    cd $repo;make;sudo make install;cd ..
#done


##########################
# Clone the Succless repository
git clone https://github.com/yuuushio/Succless.git

# Go into the Succless directory
cd Succless

# Declare an array containing the component directories
# components=("dwm" "st" "dwblocks")

# Use kitty now -- better glyphs and font handling
components=("dwm" "dwblocks" "st")

# Iterate over the components and build each one
for component in "${components[@]}"; do
  echo "Building $component..."
  cd "$component"
  make
  sudo make clean install
  cd ..
  echo "$component built and installed."
done
cd
##########################


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

yay -S emptty

#systemctl enable ly
systemctl enable --now bluetooth
systemctl enable emptty
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire.service # Fix the typo "pipeiwre.service" to "pipewire.service"
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now pipewire-pulse.service
systemctl --user --now enable wireplumber

# Install nerd fonts
cd
git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1; cd nerd-fonts;./install.sh;cd ..;rm -rf nerd-fonts

### TODOs ###
# rofi config automation
# dunst config automation
# emptty config
# bluetooth config

#sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
#sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

# https://github.com/yshui/picomhttps://github.com/yshui/picom; yay -S picom
yay -S neovim-nightly
# yay -S opencl-nvidia-470xx nvidia-470xx-dkms nvidia-470xx-utils
yay -S otf-symbola jre ttf-ms-fonts ttf-mac-fonts libxft-bgra jdk powerline-fonts-git nsxiv

echo "---Restart PC---"


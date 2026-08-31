#!/bin/bash

dotfile="yadm clone git@github.com:satiku/dotfiles.git"

packages=(
	xorg-server
	xorg-xinit
	i3-wm
	i3status
	i3blocks
	i3lock
	dmenu
	alacritty     # terminal emulator
	neovim        # text editor
	qutebrowser   # web browser
	mpv           # media player
	btop          # resource monitor
	yazi          # file manager
	ueberzugpp    # yazi 
	poppler       # yazi 
	p7zip         # yazi
	ntfs-3g       # ntfs fs compatibility
	exfat-utils   # exfat fs compatibility
)


fstab=(
	"tmpfs                    /var/log"
	"tmpfs                    /var/tmp"
	"tmpfs                    /tmp"
	"tmpfs                    /var/cache/pacman/pkg"
)




blue(){
	echo -e "\033[0;34mPASS:\033[0m $1"
}

pass(){
	echo -e "\033[0;32mPASS:\033[0m $1"
}

fail(){
	echo -e "\033[0;31mFAIL:\033[0m $1"
}



cd ~

pwd 


echo ""
echo "#############################"
echo "UPDATE REPOS"
echo "#############################"
echo ""

sudo pacman -Sy

echo ""
echo "#############################"
echo "INSTALL PACKAGES"
echo "#############################"
echo ""



for pkg in "${packages[@]}"; do 
	if sudo pacman -Q "$pkg" &>/dev/null; then 
		blue $pkg
	elif ! sudo pacman -S --noconfirm  --needed "$pkg" >/dev/null; then 
		fail $pkg
	else
		pass $pkg
	fi	
done 




echo ""
echo "#############################"
echo "Check temp mounts"
echo "#############################"
echo ""


for line in "${fstab[@]}"; do 
	path=($line)

	if grep -q "$line" /etc/fstab ;then
		blue ${path[1]}
	else
		echo "adding to file";
	fi
done



echo ""
echo "#############################"
echo "Check dot files"
echo "#############################"
echo ""


if [ -d ~/.local/share/yadm/repo.git ];then 
	blue "yadm repo exists"

else
	yadm clone $dotfile
fi



yadm fetch 

if [ "$(yadm rev-list HEAD..@{u} --count)" -gt 0 ] ;then 
	if yadm pull ; then 
		pass "yadm repo updated"
	fi
else 
	blue "yadm repo current"
fi





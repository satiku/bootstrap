#!/bin/bash



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
)


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
	if ! sudo pacman -S --noconfirm  --needed "$pkg"; then 
		echo "FAIL: $pkg"
	else
		echo "OK: $pkg"
	fi
done 


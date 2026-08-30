#!/bin/bash



packages=(
	neovim
	qutebrowser
	mpv
	btop
	yazi
	ueberzugpp    # yazi 
	poppler       # yazi 
	p7zip         # yazi
)



sudo pacman -Sy

for pkg in "${packages[@]}"; do 
	if ! sudo pacman -S --noconfirm  --needed "$pkg"; then 
		echo "FAIL: $pkg"
	else
		echo "OK: $pkg"
	fi
done 


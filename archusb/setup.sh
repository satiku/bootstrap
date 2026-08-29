#!/bin/bash



packages=(
	neovim
	qutebrowser
	yazi
	ueberzugpp
)



sudo pacman -Sy

for pkg in "${packages[@]}"; do 
	if ! sudo pacman -S --noconfirm  --needed "$pkg"; then 
		echo "FAIL: $pkg"
	else
		echo "OK: $pkg"
	fi
done 


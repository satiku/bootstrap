#!/bin/bash

dotfile="git@github.com:satiku/dotfiles.git"

packages=(
	xorg-server
	xorg-xinit
	i3-wm
	i3status
	i3blocks
	i3lock
	dmenu
	picom
	feh
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
	zsh           # default shell
	unclutter     # hide idle mouse cursor
	yadm          # dotfile manager
)


fstab=(
	"tmpfs                    /var/log"
	"tmpfs                    /var/tmp"
	"tmpfs                    /tmp"
	"tmpfs                    /var/cache/pacman/pkg"
)



header(){


	echo ""
	echo "#############################"
	echo "$1"
	echo "#############################"
	echo ""

}

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


#
# Update Repos 
#

header "UPDATE REPOS"

repo_before=$(
    sudo sha256sum /var/lib/pacman/sync/*.db 2>/dev/null | sort
)

if ! sudo pacman -Sy &>/dev/null; then
    fail "update Arch repos"
else
    repo_after=$(
        sudo sha256sum /var/lib/pacman/sync/*.db 2>/dev/null | sort
    )

    if [[ "$repo_before" == "$repo_after" ]]; then
        blue "arch repos current"
    else
        pass "update arch repos"
    fi
fi





#
# Update Repos 
#

header "INSTALL PACKAGES"


for pkg in "${packages[@]}"; do 
	if sudo pacman -Q "$pkg" &>/dev/null; then 
		blue $pkg
	elif ! sudo pacman -S --noconfirm  --needed "$pkg" >/dev/null; then 
		fail $pkg
	else
		pass $pkg
	fi
	done 




header "SET DEFAULT SHELL"

zsh_path="$(command -v zsh)"
if [ -n "$zsh_path" ]; then
	current_shell="$(getent passwd "$USER" | cut -d: -f7)"
	if [ "$current_shell" = "$zsh_path" ]; then
		blue "default shell already zsh"
	elif chsh -s "$zsh_path"; then
		pass "default shell set to zsh"
	else
		fail "could not set default shell to zsh"
	fi
else
	fail "zsh not found"
fi


header "Check temp mounts"

for line in "${fstab[@]}"; do 
	path=($line)

	if grep -q "$line" /etc/fstab ;then
		blue ${path[1]}
	else
		echo "adding to file";
	fi
done


header "Check dot files"

if [ -d ~/.local/share/yadm/repo.git ];then 
	blue "yadm repo exists"

else
	yadm clone "$dotfile"
fi



yadm fetch 

if [ "$(yadm rev-list HEAD..@{u} --count)" -gt 0 ] ;then 
	if yadm pull ; then 
		pass "yadm repo updated"
	fi
else 
	blue "yadm repo current"
fi




# Install AUR helper (yay-bin avoids Go compile / connection refused)

header "Install AUR"

if command -v yay &>/dev/null; then
	blue "yay"
else
	yay_build="$(mktemp -d)"
	if sudo pacman -S --noconfirm --needed base-devel git &>/dev/null \
		&& git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$yay_build" \
		&& (cd "$yay_build" && makepkg -si --noconfirm); then
		pass "Install yay"
	else
		fail "Install yay"
	fi
	rm -rf "$yay_build"
fi

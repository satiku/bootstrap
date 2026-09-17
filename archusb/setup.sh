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


# Install prebuilt yay when AUR git / Go module fetch fails (common connection refused).
install_yay(){
	local yay_build arch ver tarball extract

	# Go (and some helpers) read /etc/resolv.conf directly; stub link fixes [::1]:53 refused.
	if [ -f /run/systemd/resolve/stub-resolv.conf ] && [ ! -L /etc/resolv.conf ]; then
		sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
	fi

	if ! sudo pacman -S --noconfirm --needed base-devel git curl &>/dev/null; then
		return 1
	fi

	yay_build="$(mktemp -d)"

	# 1) Prefer yay-bin from AUR snapshot over git clone (HTTPS, no Go compile)
	if curl -fsSL "https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz" \
		| tar -xz -C "$yay_build" \
		&& (cd "$yay_build/yay-bin" && makepkg -si --noconfirm); then
		rm -rf "$yay_build"
		return 0
	fi

	# 2) Fallback: AUR git clone of yay-bin
	rm -rf "$yay_build"
	yay_build="$(mktemp -d)"
	if git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$yay_build/yay-bin" \
		&& (cd "$yay_build/yay-bin" && makepkg -si --noconfirm); then
		rm -rf "$yay_build"
		return 0
	fi

	# 3) Last resort: official GitHub release binary (no AUR at all)
	rm -rf "$yay_build"
	yay_build="$(mktemp -d)"
	arch="$(uname -m)"
	case "$arch" in
		x86_64|aarch64) ;;
		armv7l) arch="armv7h" ;;
		*) rm -rf "$yay_build"; return 1 ;;
	esac

	ver="$(curl -fsSL https://api.github.com/repos/Jguer/yay/releases/latest \
		| sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -1)"
	if [ -z "$ver" ]; then
		rm -rf "$yay_build"
		return 1
	fi

	tarball="yay_${ver}_${arch}.tar.gz"
	if curl -fsSL "https://github.com/Jguer/yay/releases/download/v${ver}/${tarball}" \
		| tar -xz -C "$yay_build"; then
		extract="$yay_build/yay_${ver}_${arch}"
		if [ -x "$extract/yay" ] && sudo install -Dm755 "$extract/yay" /usr/bin/yay; then
			rm -rf "$yay_build"
			return 0
		fi
	fi

	rm -rf "$yay_build"
	return 1
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




echo ""
echo "#############################"
echo "SET DEFAULT SHELL"
echo "#############################"
echo ""

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




# Install AUR YAY 

header "Install AUR"

if command -v yay &>/dev/null; then
	blue "yay"
elif install_yay; then
	pass "Install yay"
else
	fail "Install yay"
fi

#!/bin/bash

HOME="~"

# Updated ubuntu
sudo apt update \
&& apt upgrade -y


# Install alacritty
sudo apt install -y alacritty
echo `alacritty -V`

# Set fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip FiraCode.zip -d FiraCode
rm -rf $HOME/.local/share/fonts
mkdir $HOME/.local/share/fonts
mv FiraCode/*.ttf $HOME/.local/share/fonts/.
fc-cache -fv
rm FiraCode.zip
rm -rf FiraCode/

# Set alacritty toml file
mkdir $HOME/.config/alacritty/
cp ./alacritty.toml $HOME/.config/alacritty/alacritty.toml

# Import alacritty themes
mkdir -p $HOME/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes

# Install Starship
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

# Install zsh
sudo apt install -y \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting

cp ./.zshrc $HOME/.zshrc

chsh -s /usr/bin/zsh
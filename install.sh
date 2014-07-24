#!/bin/sh

if [ ! -d "$HOME/.dotfiles" ]; then
  echo "Source dotfiles must exist at $HOME/.dotfiles"
  exit 1
fi

# Create directories
mkdir -p $HOME/.config/fish/functions
mkdir -p $HOME/.imapfilter
mkdir -p $HOME/.teamocil
mkdir -p $HOME/.vim/colors

# Link dotfile
ln -s $HOME/.dotfiles/fish/config.fish $HOME/.config/fish/config.fish
ln -s $HOME/.dotfiles/fish/prompt.fish $HOME/.config/fish/functions/prompt.fish

ln -s $HOME/.dotfiles/hg/hgrc $HOME/.hgrc

ln -s $HOME/.dotfiles/imapfilter/config.lua $HOME/.imapfilter/config.lua
ln -s $HOME/.dotfiles/imapfilter/info.lua $HOME/.imapfilter/info.lua
ln -s $HOME/.dotfiles/imapfilter/wez.lua $HOME/.imapfilter/wez.lua

ln -s $HOME/.dotfiles/teamocil/alex.yml $HOME/.teamocil/alex.yml

ln -s $HOME/.dotfiles/tmux/tmux.conf $HOME/.tmux.conf

ln -s $HOME/.dotfiles/vim/vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/vim/colors/solarized.vim $HOME/.vim/colors/solarized.vim

#!/bin/sh

if [ ! -d "$HOME/.dotfiles" ]; then
  echo "Source dotfiles must exist at $HOME/.dotfiles"
  exit 1
fi

# Create directories
mkdir -p $HOME/.config

# Link dotfile
ln -s $HOME/.dotfiles/fish/ $HOME/.config/fish
ln -s $HOME/.dotfiles/hg/hgrc $HOME/.hgrc
ln -s $HOME/.dotfiles/imapfilter/ $HOME/.imapfilter
ln -s $HOME/.dotfiles/tmux/tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/vim/vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/vim/vim $HOME/.vim/

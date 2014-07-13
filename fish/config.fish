
# Put homebrew items first
set PATH /usr/local/bin $PATH

# Ruby environments
set PATH $HOME/.rbenv/shims $PATH
set PATH $HOME/.rbenv/bin $PATH
rbenv rehash >/dev/null ^&1


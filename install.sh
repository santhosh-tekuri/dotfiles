echo source `pwd`/.bashrc >> ~/.bashrc
echo source `pwd`/.zshrc >> ~/.zshrc
echo source `pwd`/.vimrc >> ~/.vimrc
echo source `pwd`/.screenrc >> ~/.screenrc
ln -s `pwd`/.inputrc ~
ln -s `pwd`/.tmux.conf ~
ln -s `pwd`/.gitconfig ~
ln -s `pwd`/gitignore ~/.gitignore

mkdir -p ~/.config
ln -s `pwd`/helix ~/.config
ln -s `pwd`/nvim ~/.config
ln -s `pwd`/wezterm ~/.config
ln -s `pwd`/ghostty ~/.config

mkdir -p ~/.ssh
echo Include `pwd`/.ssh/config >> ~/.ssh/config

# install zsh plugins
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/zsh-users/zsh-history-substring-search.git
git clone https://github.com/Aloxaf/fzf-tab

# install vim gitgutter
mkdir -p ~/.vim/pack/airblade/start
cd ~/.vim/pack/airblade/start
git clone https://github.com/airblade/vim-gitgutter.git
vim -u NONE -c "helptags vim-gitgutter/doc" -c q
cd -

# install vim markdown
cd ~/.vim
curl -L https://github.com/preservim/vim-markdown/archive/master.tar.gz |  tar --strip=1 -zx
cd -

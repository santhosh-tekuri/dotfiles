echo source `pwd`/.zshrc >> ~/.zshrc
echo source `pwd`/.vimrc >> ~/.vimrc
ln -s `pwd`/.inputrc ~
ln -s `pwd`/.screenrc ~
ln -s `pwd`/.tmux.conf ~
ln -s `pwd`/.gitconfig ~
echo source `pwd`/.bashrc >> ~/.bashrc

mkdir -p ~/.ssh
echo Include `pwd`/.ssh/config >> ~/.ssh/config

# install vim gitgutter
mkdir -p ~/.vim/pack/airblade/start
cd ~/.vim/pack/airblade/start
git clone https://github.com/airblade/vim-gitgutter.git
vim -u NONE -c "helptags vim-gitgutter/doc" -c q
cd -

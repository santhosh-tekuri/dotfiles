echo source `pwd`/.zshrc >> ~/.zshrc
echo source `pwd`/.vimrc >> ~/.vimrc
ln -s `pwd`/.inputrc ~
ln -s `pwd`/.screenrc ~
ln -s `pwd`/.tmux.conf ~
ln -s `pwd`/.gitconfig ~
echo source `pwd`/.bashrc >> ~/.bashrc

mkdir -p ~/.ssh
ln -s `pwd`/.ssh/config ~/.ssh/config

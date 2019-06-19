" downloaded from https://raw.githubusercontent.com/hashicorp/vagrant/master/contrib/vim/vagrantfile.vim

" Teach vim to syntax highlight Vagrantfile as ruby
"
" Install: $HOME/.vim/plugin/vagrant.vim
" Author: Brandon Philips <brandon@ifup.org>

augroup vagrant
	au!
	au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END

---
layout: post
title: "使用vim作为bash,Perl,Python的IDE"
category: vim
tags: [pathogen, perl-support, bash-support, python]
---

*****

### [vim使用pathogen](http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/)

[pathogen](https://github.com/tpope/vim-pathogen)的管理模块，能加载例如***~/.vim/bundle***的vim模块，这样我就不需要把所有vim模块放在***~/.vim/***上了。


#### 安装vim-pathogen,并设置autorun运行这个vim-pathogen

假设这个.vim已经在.git上的软链接

```
cd ~/.vim/
mkdir ~/.vim/bundle
git submodule add https://github.com/tpope/vim-pathogen bundle/vim-pathogen
ln -s bundle/vim-pathogen/autoload autoload
```

安装后应该是这样：

```
$ ll
total 4.0K
lrwxrwxrwx  1 kk kk   28 2015-04-01 15:31 autoload -> bundle/vim-pathogen/autoload/
drwxr-xr-x 11 kk kk 4.0K 2015-04-03 10:47 bundle/
```

#### 添加vimrc信息

```
cat >> ~/.vimrc < EOF

" There are a couple of lines that you should add to your .vimrc file to activate pathogen.
"call pathogen#runtime_append_all_bundles()
" for Upgrading all bundled plugins, run following:
" git submodule foreach git pull origin master
call pathogen#infect()
call pathogen#helptags()

EOF
```

#### 其他模块，perl-support, bash-support 等

安装pathogen后，直接在***~/.vim/bundle***上下载需要的vim模块来使用

```
cd ~/.vim/bundle/
git submodule add https://github.com/vim-scripts/bash-support.vim 
git submodule add https://github.com/vim-scripts/perl-support.vim
```

安装的实体文件在***.git/modules/***

升级：

```
git submodule foreach git pull origin master
```

#### ~~dirty tree~~

~~just involves adding the line ignore = dirty to the .gitmodules file for each submodule that reports a dirty tree when you run git status~~

```
 $ cat .gitmodules 
[submodule "linux/home/kk/.vim/bundle/vim-pathogen"]
    path = linux/home/kk/.vim/bundle/vim-pathogen
    url = https://github.com/tpope/vim-pathogen
[submodule "linux/home/kk/.vim/bundle/perl-support.vim"]
    path = linux/home/kk/.vim/bundle/perl-support.vim
    url = https://github.com/vim-scripts/perl-support.vim
    ignore = dirty
[submodule "linux/home/kk/.vim/bundle/bash-support.vim"]
    path = linux/home/kk/.vim/bundle/bash-support.vim
    url = https://github.com/vim-scripts/bash-support.vim
    ignore = dirty
[submodule "linux/home/kk/.vim/bundle/vim-surround"]
    path = linux/home/kk/.vim/bundle/vim-surround
    url = https://github.com/tpope/vim-surround
[submodule "linux/home/kk/.vim/bundle/tComment"]
    path = linux/home/kk/.vim/bundle/tComment
    url = https://github.com/vim-scripts/tComment
    ignore = dirty
[submodule "linux/home/kk/.vim/bundle/mru.vim"]
    path = linux/home/kk/.vim/bundle/mru.vim
    url = https://github.com/vim-scripts/mru.vim
```

---

### [Git - how to track untracked content?](http://stackoverflow.com/questions/4161022/git-how-to-track-untracked-content)


>I just had the same problem. The reason was because there was a subfolder that contained a ".git" folder. Removing it made git happy.

*****

### perl debugger pressing

在vim 的perl-support中，有个bug，不能使用***\rd***来调用debugger，经常出现***xterm: command not found***的错误，原因是vim会查找是否运行gui并调用xterm来debug，但我不需要。所以修改一下:



```
perl-support.vim/plugin/perl-support.vim :

diff ~/.vim/bundle/perl-support.vim/plugin/perl-support.vim ~/.vim/bundle/perl-support.vim/plugin/perl-support.vim.bak 
1243c1243
<       if has("gui_running") 
---
>       if has("gui_running") || &term == "xterm"
```

*****

### perl evn

除了第一句***shebang line***声明perl路径，可以有[其他方法](http://stackoverflow.com/questions/10059806/do-i-need-to-include-usr-bin-perl-line-in-perl-script-on-windows)：


有环境变量：

```
#!/usr/bin/env perl
```

有eval运行：

```
#!/usr/bin/perl
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}' if 0;
```


*****

### python

####  vimrc add python run, pdb debugger, syntax check, and doc

```
+autocmd FileType python nnoremap <buffer> \rr :exec '!python' shellescape(@%, 1)<cr>
+autocmd FileType python nnoremap <buffer> \rd :exec '!python -m pdb' shellescape(@%, 1)<cr>
+autocmd FileType python nnoremap <buffer> \rs :exec '!python -m py_compile' shellescape(@%, 1)<cr>
+autocmd FileType python nnoremap <buffer> K :<C-u>execute "!pydoc " . expand("<cword>")<CR>
```

####  [python style](http://blog.dispatched.ch/2009/05/24/vim-as-python-ide/)

```

set tabstop=8
set softtabstop=4
set shiftwidth=4

" http://blog.dispatched.ch/2009/05/24/vim-as-python-ide/
" PEP 8(Pythons' style guide) and to have decent eye candy:
"set expandtab
" set textwidth=79
set tabstop=8
set softtabstop=4
set shiftwidth=4
```

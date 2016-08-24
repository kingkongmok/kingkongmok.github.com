" Vim5 and later versions support syntax highlighting. Uncommenting the
" following enables syntax highlighting by default.
if has("syntax")
  syntax on
endif


" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned
set nu
set hls

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
 set background=dark
map <F10> :let &background = ( &background == "dark"? "light" : "dark" )<CR>

" F5 to print time
:nnoremap <F5> "=strftime("%c")<CR>P
:inoremap <F5> <C-R>=strftime("%c")<CR>

" set nonumb by pressing contrl-n twice
:nmap <C-N><C-N> :set invnumber<CR>


" nohighlight for bars on mutriWindows 设置多窗口的分割栏颜色
hi StatusLine ctermfg=39 ctermbg=239 cterm=None
hi StatusLineNC ctermfg=39 ctermbg=239 cterm=None
hi VertSplit ctermfg=39 ctermbg=239 cterm=None


" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

:filetype plugin on

" setting for MRU
map <leader>f :MRU<CR>
highlight link MRUFileName LineNr
let MRU_Max_Entries = 1000
" let MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'  " For Unix

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"
"set paste          " comment后，在调用perl-support这些方法时候比较方便，换号自动tab
"
if has("autocmd")
  filetype plugin indent on
endif
set smartindent
"set tabstop=4
"set shiftwidth=4
set expandtab
set visualbell t_vb=
set t_Co=256
" You won't usually regret turning this feature on, but if you ever find it
" annoying—say, you switch from writing a script to writing a letter and a
" <tab> no longer indicates the beginning of a code block—you can turn it off
" with this command:
set autoindent
" press F8 to disable autoindent http://vim.wikia.com/wiki/How_to_stop_auto_indenting
":nnoremap <F8> :setl noai nocin nosi inde=<CR>
:nnoremap <F8> :setl si paste! si paste?<CR> 
" (update - add this to your vimrc to block the autoindenting of comments - no
" other solution on this page works):-
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Pathogen.vim 
" http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/
" There are a couple of lines that you should add to your .vimrc file to activate pathogen.
"call pathogen#runtime_append_all_bundles()
" for Upgrading all bundled plugins, run following:
" git submodule foreach git pull origin master
call pathogen#infect()
call pathogen#helptags()


" set wrap http://vim.wikia.com/wiki/Word_wrap_without_line_breaks
" wrap tells Vim to word wrap visually (as opposed to changing the text in the
" buffer)
set wrap
"  linebreak tells Vim to only wrap at a character in the breakat option (by
"  default, this includes " ^I!@*-+;:,./?" (note the inclusion of " " and that
"  ^I is the control character for Tab)).
set linebreak
set nolist  " list disables linebreak
"set tw=78
"set formatoptions+=t

" vim scans all included files, change complete to DISABLE this.
" http://stackoverflow.com/questions/2169645/vims-autocomplete-is-excruciatingly-slow
set complete-=i

" http://blog.dispatched.ch/2009/05/24/vim-as-python-ide/
" PEP 8(Pythons' style guide) and to have decent eye candy:
"set expandtab
" set textwidth=79
set tabstop=8
set softtabstop=4
set shiftwidth=4

" " run python
" autocmd FileType python nnoremap <buffer> \rr :exec '!python' shellescape(@%, 1)<cr>
" autocmd FileType python nnoremap <buffer> \rd :exec '!python -m pdb' shellescape(@%, 1)<cr>
" autocmd FileType python nnoremap <buffer> \rs :exec '!python -m py_compile' shellescape(@%, 1)<cr>
" autocmd FileType python nnoremap <buffer> K :<C-u>execute "!pydoc " . expand("<cword>")<CR>

" Revision History wich Gundo plugin.
map <leader>g :GundoToggle<CR>

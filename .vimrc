" vim: ts=4 sw=4

" SETTINGS
set nocompatible
set backspace=indent,eol,start
set nobackup
set dir=~
set history=1024
set showcmd
set incsearch
set showmode
set statusline=%f\ \(%n\)\ %y%r%m%w\ %=L[%l/%L]\ %6(C[%v]%)\ %6([%p%%]%)
set laststatus=2
set mousehide
set autoindent
set cpoptions+=n
set listchars=tab:>.,trail:.,eol:$
set wildmode=list:longest
set scrolloff=2
set sidescrolloff=2
set display=lastline 
set switchbuf=split

" Enable Go plugins
if isdirectory($GOROOT)
	set rtp+=$GOROOT/misc/vim
endif

" ------------------------------------------------------------------
"  Vundle

"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()

"Bundle 'gmarik/vundle'

" ------------------------------------------------------------------

syntax on
set hlsearch
nohlsearch

filetype plugin indent on

autocmd FileType text setlocal textwidth=100

set background=light

" ============================================================================
" MAPPINGS

" Don't use Ex mode, use Q for formatting

imap    <C-C>   <Esc>:q<CR>
nmap    <C-C>   <Esc>:q<CR>
vmap    <C-C>   <Esc>:q<CR>

map <C-j> :tabprev<CR>
map <C-k> :tabnext<CR>

map     <F2>    :w<CR>
imap    <F2>    <Esc>:w<CR>l

map     <S-F4>  :cprev<CR>
map     <F4>    :cnext<CR>

map     <F5>    :bprev<CR>

map     <F6>    :bnext<CR>

map     <F10>   :close<CR>
map     <S-F10> :ptnext<CR>
imap    <S-F10> <Esc>:ptnext<CR>


"Cursor one line at a time when :set wrap
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

set fileencodings=utf-8
set shiftwidth=4
set tabstop=4
set noexpandtab
set wrap

" ============================================================================
" Commands
:command! -nargs=1 -range Retab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g

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

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if has("terminfo")
	set t_Co=8
	set t_Sf=<Esc>[3%p1%dm
	set t_Sb=<Esc>[4%p1%dm
else
	set t_Co=8
	set t_Sf=<Esc>[3%dm
	set t_Sb=<Esc>[4%dm
endif

call pathogen#infect()

" Enable Go plugins
if isdirectory($GOROOT)
	set rtp+=$GOROOT/misc/vim
endif

syntax on
set hlsearch
nohlsearch

filetype plugin indent on

autocmd FileType text setlocal textwidth=100

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

let g:pydiction_location = '~/vimfiles/ftplugin/complete-dict' 

autocmd FileType python set omnifunc=pythoncomplete#Complete; 
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

set background=light

"
" GUI Settings
"

if has("gui_running")
	"set background=dark
	"colorscheme zoid
	"colorscheme macvim
	"colorscheme solarized
endif


" ============================================================================
" MAPPINGS

" Don't use Ex mode, use Q for formatting
map             Q               gq

map             <M-j>   <C-e>j
map             <M-k>   <C-y>k

imap    <C-C>   <Esc>:q<CR>
nmap    <C-C>   <Esc>:q<CR>
vmap    <C-C>   <Esc>:q<CR>

map <C-j> :tabprev<CR>
map <C-k> :tabnext<CR>

map             <F2>    :w<CR>
imap    <F2>    <Esc>:w<CR>l

map             <S-F4>  :cprev<CR>
map             <F4>    :cnext<CR>

map             <F5>    :bprev<CR>

map             <F6>    :bnext<CR>

map     <F7>    :ccl<CR>
map     <S-F7>  :cw<CR>

map     <F8>    :Tlist<CR>

map             <S-F9>  :ccl<CR>
imap    <S-F9>  <Esc>:ccl<CR>
map             <C-F9>  :10wincmd j<CR>
imap    <C-F9>  <Esc>:10wincmd j<CR>

map             <F10>   :close<CR>
map             <S-F10> :ptnext<CR>
imap    <S-F10> <Esc>:ptnext<CR>
map             <SM-F10> :ptp<CR>
imap    <SM-F10> <Esc>:ptp<CR>

map             <F11>   zC
imap    <F11>   <Esc>zCi 
map             <S-F11> zc

map             <F12>   zO
imap    <F12>   <Esc>zOi

"imap ,/ </<C-X><C-O>


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

execute pathogen#infect()

syntax on
filetype plugin indent on

let g:onedark_termcolors=256

let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords

let g:airline_theme='onedark'
let g:airline_extensions = ['branch', 'hunks']


set nocompatible
filetype off

set t_Co=256

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'flazz/vim-colorschemes'
Plug 'rakr/vim-one'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'octol/vim-cpp-enhanced-highlight'

Plug 'JuliaEditorSupport/julia-vim'

call plug#end()
" --------------------------------------------------------------------
" Settings
" --------------------------------------------------------------------
set nowrap
set showcmd
set autoindent
set softtabstop=4
set shiftwidth=4
set expandtab
set sessionoptions=blank,buffers,sesdir,folds,help,options,winsize,winpos,resize
set grepprg=grep\ -nH\ $*
set textwidth=179
set winaltkeys=no
set complete-=i
set nobackup
set virtualedit=block
set laststatus=2
set fileencodings=utf-8,cp1251
set viminfo='1000,<50,s10,c,h
set history=100
set secure
set previewheight=8
set incsearch
set spelllang=en
set makeprg=Make
set tags+=build/tags
set wildmenu
set wildmode=longest,list,full
set mousemodel=popup
set t_Co=16
set hls
nohlsearch

" --------------------------------------------------------------------
let fortran_free_source=1
let fortran_have_tabs=1
let fortran_more_precise=1
let fortran_do_enddo=1
let g:Imap_FreezeImap=1
let g:Imap_UsePlaceHolders=0
let g:Tex_SmartKeyQuote=0
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_CompileRule_pdf='make -C build'
let c_space_errors=1
let g:load_doxygen_syntax=1
let pascal_delphi=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Show_One_File=1
let g:tagbar_autofocus=1
let g:tagbar_sort=0
let g:tagbar_compact=1

" --------------------------------------------------------------------
" Restore the last position
" --------------------------------------------------------------------
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END
" --------------------------------------------------------------------

au BufNewFile,BufRead *.maxj setf java
au BufNewFile,BufRead *.cl setf opencl
au BufNewFile,BufRead *.cuh setf cuda
autocmd Filetype gitcommit setlocal textwidth=72

highlight SpellErrors guifg=Red gui=underline
let c_no_curly_error=1

hi clear SignColumn
hi link SignColumn            Keyword
hi link GitGutterAdd          Keyword
hi link GitGutterChange       String
hi link GitGutterDelete       String
hi link GitGutterChangeDelete String

" --------------------------------------------------------------------
" Commands
" --------------------------------------------------------------------
" :Make opens error window in case any error occured.
command -nargs=* Make make <args> | cwindow 6
command -nargs=* Grep grep <args> | cwindow 6

" --------------------------------------------------------------------
" Mappings
" --------------------------------------------------------------------
map <F9>    :syn sync fromstart<Enter>:nohl<Enter>
map <F1>    :Man <Enter>
map <F2>    :cn<Enter>
map <F8>    :NERDTreeToggle<Enter>
map <F10>   :TagbarToggle<Enter>
map <S-F10> :FZF<Enter>
map <F12>   :Make<Enter>

" --------------------------------------------------------------------
" Last strokes
" --------------------------------------------------------------------
" Turn on russian keymap
if !&readonly
    set keymap=russian-jcukenwin
    set iminsert=0
    set imsearch=-1
endif

" --------------------------------------------------------------------
" AutoCommands
" --------------------------------------------------------------------
" Insert c/c++ gates when creating new header files.
autocmd BufNewFile *.{h,hpp} call InsertHgates()

" Insert script header for new scripts.
autocmd BufNewFile *.pl      call ScriptHead("/usr/bin/perl -w")
autocmd BufNewFile *.sh      call ScriptHead("/bin/bash")
autocmd BufNewFile *.sge     call SGEHead()

" Edit afiedt.buf as sql file.
autocmd BufNewFile afiedt.buf set filetype=sql

" Allow formatting of numbered lists in text files.
autocmd BufNewFile *.txt set formatoptions+=n

" Set keymap in latex files
autocmd BufNewFile *.tex set keymap=russian-jcukenwin

" Fugitive commands
autocmd BufReadPost fugitive://* set bufhidden=delete

" --------------------------------------------------------------------
"  Function definitions
" --------------------------------------------------------------------
" Create c/c++ gates in new headers
function InsertHgates()
    let gatename = substitute(toupper(expand("%:.")), "\\(\\.\\|/\\)", "_", "g")
    execute "normal i#ifndef " . gatename
    execute "normal o#define " . gatename
    execute "normal 3o"
    execute "normal o#endif"
    normal kk
endfunction

" Insert shell header
function ScriptHead(line)
    execute "normal i#!" . a:line
    normal o
endfunction

" Insert SGE Job header
function SGEHead()
    execute "normal i#!/bin/bash"
    execute "normal o#$ -V -j y -cwd"
    execute "normal o#$ -N " . expand("%:t")
endfunction

" vim: foldmethod=marker
"
"
"

map <C-Tab> :tabnext<Enter>
map <C-q>   :tabprev<Enter>
nnoremap y yy
nnoremap d dd
inoremap ii <Esc>
nnoremap <C-n> :tabedit 

set nocompatible  " Must be first line

" Force python3
if has('python3')
endif

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'mbbill/undotree'
Plug 'ervandew/supertab'

Plug 'ctrlpvim/ctrlp.vim'
Plug 'raghur/fruzzy', {'do': { -> fruzzy#install()}}


Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'elixir-editors/vim-elixir'

" Initialize plugin system
call plug#end()

"Plugin 'tpope/vim-fugitive'
"Plugin 'Lokaltog/vim-easymotion'
"Plugin 'mileszs/ack.vim'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'davidhalter/jedi-vim.git'

"Plugin 'skammer/vim-css-color'

" TODO potentially remove
"Plugin 'terryma/vim-multiple-cursors'

"Plugin 'Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'}
"Plugin 'godlygeek/csapprox'
"Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'airblade/vim-gitgutter'
"Plugin 'scrooloose/nerdcommenter'
"Plugin 'w0rp/ale'


" TODO potentially use, settings below
" Plugin 'klen/python-mode'

"Plugin 'pangloss/vim-javascript'
"Plugin 'mxw/vim-jsx'
"Plugin 'elzr/vim-json'
"Plugin 'hail2u/vim-css3-syntax'
"Plugin 'tpope/vim-haml'
"Plugin 'slim-template/vim-slim.git'
"Plugin 'tpope/vim-rails.git'
"Plugin 'vim-ruby/vim-ruby.git'
"Plugin 'ngmy/vim-rubocop'
"Plugin 'tpope/vim-bundler.git'
"Plugin 'chase/vim-ansible-yaml'

"Plugin 'freitass/todo.txt-vim'

"Plugin 'hashivim/vim-terraform'

filetype plugin indent on " Automatically detect file types.

set background=dark
colorscheme paintbox

syntax on                 " Syntax highlighting
set mouse=a               " Automatically enable mouse usage
set mousehide             " Hide the mouse cursor while typing
scriptencoding utf-8

if has ('x') && has ('gui') " On Linux use + register for copy-paste
    set clipboard=unnamedplus
elseif has ('gui')          " On Mac and Windows, use * register for copy-paste
    set clipboard=unnamed
endif

" Rarely ever use old sh, generally bash
let is_bash="true"

set shortmess+=filmnrxoOtT " Abbrev. of messages (avoids 'hit enter')
set history=1000           " Store a ton of history (default is 20)
set hidden                 " Allow buffer switching without saving
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility

set spell
set spell spelllang=en
set dictionary=/usr/share/dict/words

 " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Restore cursor to file position in previous editing session
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

set backup               " Backups are nice ...
if has('persistent_undo')
    set undofile         " So is persistent undo ...
    set undolevels=1000  " Maximum number of changes that can be undone
    set undoreload=10000 " Maximum number lines to save for undo on a buffer reload
endif

function! InitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let common_dir = parent . '/.' . prefix
    let dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }

    if has('persistent_undo')
        let dir_list['undo'] = 'undodir'
    endif

    for [dirname, settingname] in items(dir_list)
        let directory = common_dir . dirname . '/'
        if exists("*mkdir")
            if !isdirectory(directory)
                call mkdir(directory)
            endif
        endif
        if !isdirectory(directory)
            echo "Warning: Unable to create backup directory: " . directory
            echo "Try: mkdir -p " . directory
        else
            let directory = substitute(directory, " ", "\\\\ ", "g")
            exec "set " . settingname . "=" . directory
        endif
    endfor
endfunction
call InitializeDirectories()

set showmode   " Display the current mode
set cursorline " Highlight current line

" SignColumn should match background for things like vim-gitgutter
highlight clear SignColumn

" Current line number row will have same background color
" in relative mode. Things like vim-gitgutter will match LineNr highlight
highlight clear LineNr

"if has('cmdline_info')
"   set ruler   " Show the ruler
"   set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
"   set showcmd " Show partial commands in status line and selected characters/lines in visual mode
"endif

"if has('statusline')
"    set laststatus=2
"
"    " Broken down into easily includeable segments
"    set statusline=%<%f\ " Filename
"    set statusline+=%w%h%m%r " Options
"    set statusline+=%{fugitive#statusline()} " Git Hotness
"    set statusline+=\ [%{&ff}/%Y] " Filetype
"    set statusline+=\ [%{getcwd()}] " Current dir
"    set statusline+=%=%-14.(%l,%c%V%)\ %p%% " Right aligned file nav info
"endif

set backspace=indent,eol,start " Backspace for dummies
set linespace=0                " No extra spaces between rows
set nu                         " Line numbers on
set showmatch                  " Show matching brackets/parenthesis
set incsearch                  " Find as you type search
set nohlsearch                 " Highlight search terms
set winminheight=0             " Windows can be 0 line high
set ignorecase                 " Case insensitive search
set smartcase                  " Case sensitive when uc present
set wildmenu                   " Show list instead of just completing
set wildmode=list:longest,full " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]  " Backspace and cursor keys wrap too
set scrolljump=5               " Lines to scroll when cursor leaves screen
set scrolloff=3                " Minimum lines to keep above and below cursor
set foldenable                 " Auto fold code
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

set nowrap            " Do not wrap long lines
set autoindent        " Indent at the same level of the previous line
set shiftwidth=4      " Use indents of 4 spaces
set expandtab         " Tabs are spaces, not tabs
set tabstop=4         " An indentation every four columns
set softtabstop=4     " Let backspace delete indent
set shiftround        " Rounds shifting via '</>' to multiple of shiftwidth
set nojoinspaces      " Prevents inserting two spaces after punctuation on a join (J)
set splitright        " Puts new vsplit windows to the right of the current
set splitbelow        " Puts new split windows to the bottom of the current
set pastetoggle=<F12> " pastetoggle (sane indentation on pastes)

inoremap <silent> <C-g> <ESC>u:set paste<CR>.:set nopaste<CR>gi
inoremap jj <esc>

" Some filetype-specific stuff

" Makefiles don't like spaces
autocmd FileType make set noexpandtab

autocmd FileType go autocmd BufWritePre <buffer> Fmt

" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

au FileType yaml setl sw=2 sts=2 et
au FileType ruby setl sw=2 sts=2 et
au FileType slim setl sw=2 sts=2 et
au FileType sass setl sw=2 sts=2 et
au FileType scss setl sw=2 sts=2 et
au FileType javascript.jsx setl sw=2 sts=2 et
au FileType javascript setl sw=2 sts=2 et

au FileType apache set spell nospell
au FileType conf set spell nospell
au FileType make set spell nospell

" Remove trailing whitespaces and ^M chars in programs
function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
autocmd FileType c,cpp,java,go,php,ruby,javascript,python,haml,xml,yml autocmd BufWritePre <buffer> call StripTrailingWhitespace()

let mapleader = '\'

" Easier moving in tabs and windows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk
" Same for 0, home, end, etc
noremap $ g$
noremap <End> g<End>
noremap 0 g0
noremap <Home> g<Home>
noremap ^ g^

" Stupid shift key fixes
if has("user_commands")
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Code folding options
nmap <leader>f0 :set foldlevel=0<CR>
nmap <leader>f1 :set foldlevel=1<CR>
nmap <leader>f2 :set foldlevel=2<CR>
nmap <leader>f3 :set foldlevel=3<CR>
nmap <leader>f4 :set foldlevel=4<CR>
nmap <leader>f5 :set foldlevel=5<CR>
nmap <leader>f6 :set foldlevel=6<CR>
nmap <leader>f7 :set foldlevel=7<CR>
nmap <leader>f8 :set foldlevel=8<CR>
nmap <leader>f9 :set foldlevel=9<CR>

" Toggle search highlighting
nmap <silent> <leader>/ :set invhlsearch<CR>

" Find merge conflict markers
map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Some helpers to edit mode
" http://vimcasts.org/e/14
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Adjust viewports to the same size
map <Leader>= <C-w>=

" Map <Leader>ff to display all lines with keyword under cursor
" and ask which one to jump to
nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Easier horizontal scrolling
map zl zL
map zh zH

nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>

" Plugin-specific configuration

" PyMode TODO figure out whether to use, from spf13
" let g:pymode_lint_checker = "pyflakes"
" let g:pymode_utils_whitespaces = 0
" let g:pymode_options = 0

" ctrlp / fruzzy
let g:fruzzy#usenative = 1
let g:fruzzy#sortonempty = 1

let g:ctrlp_working_path_mode = 'ra'
nnoremap <silent> <Leader>t :CtrlP<CR>
nnoremap <silent> <Leader>y :CtrlPMRU<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <silent> <Leader>f :ClearCtrlPCache<CR>

let g:ctrlp_custom_ignore = {
    \ 'dir': '\.git$\|\.hg$\|\.svn$|spec/vcr_cassettes',
    \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$'
\ }

let g:ctrlp_user_command = {
    \ 'types': {
        \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
    \ 'fallback': 'find %s -type f'
\ }
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_match_func = {'match': 'fruzzy#ctrlp#matcher'}
let g:ctrlp_match_current_file = 1 " to include current file in matches

 " Fugitive
"nnoremap <silent> <leader>gs :Gstatus<CR>
"nnoremap <silent> <leader>gd :Gdiff<CR>
"nnoremap <silent> <leader>gc :Gcommit<CR>
"nnoremap <silent> <leader>gb :Gblame<CR>
"nnoremap <silent> <leader>gl :Glog<CR>
"nnoremap <silent> <leader>gp :Git push<CR>
"nnoremap <silent> <leader>gr :Gread<CR>:GitGutter<CR>
"nnoremap <silent> <leader>gw :Gwrite<CR>:GitGutter<CR>
"nnoremap <silent> <leader>ge :Gedit<CR>
"nnoremap <silent> <leader>gg :GitGutterToggle<CR>

" gitgutter
"set signcolumn=yes

" UndoTree
nnoremap <Leader>u :UndotreeToggle<CR>
" If undotree is opened, it is likely one wants to interact with it.
let g:undotree_SetFocusWhenToggle=1

" indent_guides
"let g:indent_guides_start_level = 2
"let g:indent_guides_guide_size = 1
"let g:indent_guides_enable_on_vim_startup = 1

" vim-airline
let g:airline_theme = 'murmur'
let g:airline_enable_branch     = 1
"let g:airline#extensions#ale#enabled = 1
set ttimeoutlen=50

" vim-powerline symbols
let g:airline_powerline_fonts = 1
"let g:airline_left_sep          = '⮀'
"let g:airline_left_alt_sep      = '⮁'
"let g:airline_right_sep         = '⮂'
"let g:airline_right_alt_sep     = '⮃'
"let g:airline_branch_prefix     = '⭠'
"let g:airline_readonly_symbol   = '⭤'
"let g:airline_linecolumn_prefix = '⭡'

" ack
if executable('ack')
elseif executable('ag')
    let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
elseif executable('ack-grep')
    let g:ackprg="ack-grep -H --nocolor --nogroup --column"
endif

" GUI Settings
if has('gui_running')
    set guioptions-=T " Remove the toolbar
    set guioptions-=r " Remove the scrollbar
    set lines=40 " 40 lines of text instead of 24
    if has("gui_gtk2")
        set guifont=Monaco\ for\ Powerline\ 12
    elseif has("gui_macvim")
        set guifont=Monaco\ for\ Powerline:h14
    elseif has("gui_win32")
        set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
    endif
    if has('gui_macvim')
        set transparency=3 " Make the window slightly transparent
    endif
else
    if &term == 'xterm' || &term == 'screen'
        set t_Co=256 " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
    endif
endif

" Run a shell command
function! s:RunShellCommand(cmdline)
    botright new

    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nowrap
    setlocal filetype=shell
    setlocal syntax=shell

    call setline(1, a:cmdline)
    call setline(2, substitute(a:cmdline, '.', '=', 'g'))
    execute 'silent $read !' . escape(a:cmdline, '%#')
    setlocal nomodifiable
    1
endfunction

command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
" e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %

" run rubocop autoformat
nmap <leader>rc <Esc>:RuboCop -a<CR>

nmap <leader>ri <Esc>:RuboCop -a --only Style/IndentationWidth,Style/IndentationConsistency<CR>

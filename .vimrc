"""""""""""""""
"common setting
"""""""""""""""
set number
set background=dark
set ls=2
set hlsearch
set incsearch
set fileencodings=utf8,gbk,latin1

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set cindent
set autoindent

set cc=79
set cursorline
set cursorcolumn

"""""""""""
"ctags
"http://stackoverflow.com/questions/563616/vim-and-ctags-tips-and-tricks
"""""""""""
"C-] - go to definition
"C-T - Jump back from the definition.
"C-W C-] - Open the definition in a horizontal split
"
"Add these lines in vimrc
"map <C-\> :tab split<CR>:exec("tag \".expand("<cword>"))<CR>
"map <A-]> :vsp <CR>:exec("tag \".expand("<cword>"))<CR>
"
"C-\ - Open the definition in a new tab
"A-] - Open the definition in a vertical split
"
"After the tags are generated. You can use the following keys to tag into and tag out of functions:
"
"Ctrl-Left_MouseClick - Go to definition
"Ctrl-Right_MouseClick - Jump back from definition
"""""""""""
set tags=tags
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
nmap <F4> :TagbarToggle<CR>
let g:tagbar_width = 37

""""""""""""
"ignore case
""""""""""""
set ic

call pathogen#runtime_append_all_bundles()

filetype on
filetype plugin on
filetype plugin indent on

call pathogen#infect()
filetype plugin indent on
syntax enable
set background=dark
"set t_Co=16
let g:solarized_termcolors=256
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
colorscheme solarized


""""""""""""""""""
"NERDTree setting
""""""""""""""""""
nmap <F3> :NERDTreeToggle<CR>
let NERDChristmasTree = 1		" Tells the NERD tree to make itself colourful and pretty.
let NERDTreeAutoCenter =1		" Window centers when the cursor moves within a specified distance to the top/bottom of the window.
let NERDTreeAutoCenterThreshold = 3	" Controls the sensitivity of autocentering.
let NERDTreeCaseSensitiveSort = 0	" Tells the NERD tree whether to be case sensitive or not when sorting nodes.
let NERDTreeChDirMode = 0		" Tells the NERD tree if/when it should change vim's current working directory.
let NERDTreeHighlightCursorline = 1	" Tell the NERD tree whether to highlight the current cursor line.
let NERDTreeHijackNetrw = 1		" Tell the NERD tree whether to replace the netrw autocommands for exploring local directories.
let NERDTreeIgnore= ['\~$','.*\.pyc','.*\.pyo']		" Tells the NERD tree which files to ignore.
let NERDTreeBookmarksFile =$HOME.'/.NERDTreeBookmarks' " Where the bookmarks are stored.
let NERDTreeMouseMode = 2 		" Tells the NERD tree how to handle mouse clicks.
let NERDTreeQuitOnOpen = 0		" Closes the tree window after opening a file.
let NERDTreeShowBookmarks = 0		" Tells the NERD tree whether to display the bookmarks table on startup
let NERDTreeShowFiles = 1		" Tells the NERD tree whether to display files in the tree on startup.
let NERDTreeShowHidden = 0		" Tells the NERD tree whether to display hidden files on startup.
let NERDTreeShowLineNumbers = 0		" Tells the NERD tree whether to display line numbers in the tree window.
let NERDTreeSortOrder = ['\/$', '*', '\.swp$', '\.bak$', '\~$'] " Tell the NERD tree how to sort the nodes in the tree.
let NERDTreeStatusline = "%{exists('b:NERDTreeRoot')?b:NERDTreeRoot.path.str():''}" " Set a statusline for NERD tree windows.
let NERDTreeWinPos = "left"		" Tells the script where to put the NERD tree window
let NERDTreeWinSize = 21		" Sets the window size when the NERD tree is opened.


""""""""""""""""
"remove space and empty-line pre writing
""""""""""""""""
autocmd BufWritePre * silent! %s/\s\+$//
autocmd BufWritePre * silent! %s/\(\s*\n\)\+\%$//


""""""""""""""""
"mapping
""""""""""""""""

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <C-p> "+p


"""""""""""""""""""""""""""""""""""""""""""""""""
""Search for selected text, forwards or backwards.
"""""""""""""""""""""""""""""""""""""""""""""""""

vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

"au FileType javascript call JavaScriptFold()
"autocmd FileType python set complete+=k~/.vim/syntax/python.vim isk+=.,(


""""""""""""""""""
"For Onmi settings
""""""""""""""""""
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS


"""""""""""""""""""""""
"neocomplcache settings
"""""""""""""""""""""""
let g:neocomplcache_enable_at_startup = 1
"imap <C-k>     <Plug>(neocomplcache_snippets_expand)
"smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()
set completeopt-=preview

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

if has('conceal')
      set conceallevel=2 concealcursor=i
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Add header for *.py *.sh *.css *.js
"Doc: http://vim.wikia.com/wiki/Insert_current_date_or_time
"Doc: http://www.thegeekstuff.com/2008/12/vi-and-vim-autocommand-3-steps-to-add-custom-header-to-your-file/
"TODO: refine this....
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AppendPyHeader()
    call append(0, '#!/usr/bin/env python')
    call append(1, '#-*- coding:utf-8 -*-')
    call append(2, '# Author: Kun Huang <academicgareth@gmail.com>')
endfunction
autocmd BufNewFile *.py call AppendPyHeader()

function! AppendCSSHeader()
    call append(0, '/*')
    call append(1, 'Author: Kun Huang <academicgareth@gmail.com>')
    call append(2, '*/')
endfunction
autocmd BufNewFile *.css call AppendCSSHeader()

function! AppendJsHeader()
    call append(0, '/*')
    call append(1, 'Author: Kun Huang <academicgareth@gmail.com>')
    call append(2, '*/')
endfunction
autocmd BufNewFile *.js call AppendJsHeader()

function! AppendShHeader()
    call append(0, '#!/bin/bash')
    call append(1, '# Author: Kun Huang <academicgareth@gmail.com>')
endfunction
autocmd BufNewFile *.sh call AppendShHeader()

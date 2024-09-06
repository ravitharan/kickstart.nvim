
set nocompatible              " be iMproved, required


set encoding=utf-8

" split windows vertically when termdebug is intitiated
let g:termdebug_wide=1

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

:syntax enable

" add current directory in path
set path+=**

set wildmenu

:set tabstop=4
:set shiftwidth=4
:set expandtab
:set backspace=indent,eol,start
:set mouse=a

"Adjust case for auto complete
:set infercase

:set ruler showcmd showmode
:set number
:set shortmess+=|
:set clipboard=unnamedplus

" mappings
:nmap <Insert> i<CR><ESC>
:nnoremap ,f :let @+ = expand("%:t")<CR>
:nnoremap ,F :let @+ = expand("%:p")<CR>
:nnoremap ,w :let @+ = "<C-R><C-W>"<CR>
:nnoremap ,W :let @+ = "<C-R><C-A>"<CR>


:command! Bd bp|bd #

:command! -nargs=1 SFiles call SearchFiles(<q-args>)
:command! -nargs=1 SBuffers call SearchBuffers(<q-args>)
:command! -nargs=1 Open call OpenFile(<q-args>)
:command! -nargs=0 Ls call DispBuffers()
:command! -nargs=0 Ds call DeleteBuffers()
:command! -nargs=1 SFileList call ArgFiles(<q-args>)
:command! -nargs=0 CloseArgs call CloseArgFiles()
:command! -nargs=0 GdbBtArrange call GdbBtRearrange()
:command! -nargs=0 OpenSearchFile call OpenSearchFile()
:nnoremap <leader>w :SFiles "<C-R><C-W>"<CR>
:nnoremap <leader>W :SFiles "<C-R><C-A>"<CR>
:nnoremap <leader>bw :SBuffers "<C-R><C-W>"<CR>
:nnoremap <leader>Bw :SBuffers "<C-R><C-A>"<CR>
:nnoremap <leader>n :let @*=expand("%:p").":".line('.').":\t".getline(".")<CR>

:let buflist = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
:let vimcount = system("pgrep vim | wc -l")
:let vimcount = vimcount - 1
let g:Base = buflist[vimcount]
let g:FileNo = 0
let g:SearchPatterns = {}


map <F2> :mksession! ./vim_session <cr> " Quick write session with F2
map <F3> :source ./vim_session <cr>     " And load session with F3

:set dictionary-=/usr/share/dict/words dictionary+=/usr/share/dict/words
:set nospell
" Toggle spell checking on and off with `\s`
:nmap <silent> <leader>s :set spell!<CR>


:set nowrap

nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>

autocmd FileType c map <buffer> <C-B> :py3f /usr/share/vim/addons/syntax/clang-format.py<cr>
autocmd FileType c imap <buffer> <C-B> <c-o>:py3f /usr/share/vim/addons/syntax/clang-format.py<cr>

autocmd FileType python map <buffer> <C-B> :! autopep8 --in-place --aggressive --aggressive  % <cr>

autocmd Filetype gitcommit setlocal spell textwidth=72

function! GdbBtRearrange()
  :exe '%s/\n\(#\)\@!/\1/g'
  :exe '%s/^#\d\+.\{-\}in //g'
  :exe '%s/^\(.*\) at \(.*\)/\2: \1/g'
  :exe '%! tac'
  :exe 'w'
endfunction


function! SearchBuffers(pattern )
  let bl=''
  :bufdo let bl=bl.' '.expand('%')
  if a:pattern[0] == "\""
    let pattern = strpart(a:pattern,1,len(a:pattern)-2)
  else
    let pattern = a:pattern
  endif
  if strpart(pattern, len(pattern)-2, 2) == "\\c"
    :exe "! grep -in \'".strpart(pattern,0,len(pattern)-2)."\' ".bl." > /tmp/S".g:Base.g:FileNo.""
  else
    :exe "! grep -n \'".pattern."\' ".bl." > /tmp/S".g:Base.g:FileNo.""
  endif
  exe ":e /tmp/S".g:Base.g:FileNo.""
  let b:search = pattern
  let @/ = b:search
  let g:FileNo += 1
  if g:FileNo == 10
    let g:FileNo = 0
  endif
endfunction

function! SearchFiles(pattern)
  if a:pattern[0] == "\""
    let pattern = strpart(a:pattern,1,len(a:pattern)-2)
  else
    let pattern = a:pattern
  endif
  let FileNo = g:FileNo

  if strpart(pattern, len(pattern)-2, 2) == "\\c"
    exe ":! cat ".g:FileName." | xargs grep -in \'".strpart(pattern,0,len(pattern)-2)."\' > /tmp/S".g:Base.FileNo.""
  else
    exe ":! cat ".g:FileName." | xargs grep -n \'".pattern."\' > /tmp/S".g:Base.FileNo.""
  endif
  exe ":e /tmp/S".g:Base.FileNo.""
  let b:search = pattern
  let @/ = b:search

  if FileNo == g:FileNo
  "New output file is used
    let g:SearchPatterns[FileNo] = pattern
    let g:FileNo += 1
    if g:FileNo == 10
      let g:FileNo = 0
    endif
  endif
endfunction

function! ArgFiles(pattern)
  if a:pattern[0] == "\""
    let pattern = strpart(a:pattern,1,len(a:pattern)-2)
  else
    let pattern = a:pattern
  endif
  if strpart(pattern, len(pattern)-2, 2) == "\\c"
    exe ":! cat ".g:FileName." | xargs grep -il \'".strpart(pattern,0,len(pattern)-2)."\' > /tmp/Stemp"
  else
    exe ":! cat ".g:FileName." | xargs grep -l \'".pattern."\' > /tmp/Stemp"
  endif
  exe ":ar `cat /tmp/Stemp`"
  let @/ = pattern
endfunction

function! CloseArgFiles()
  let Files = readfile("/tmp/Stemp")
  if len(Files) > 1
    for File in Files
      exe ":bw ".File.""
    endfor
  endif
  exe ":! echo -n \"\" > /tmp/Stemp"
endfunction

function! DispBuffers( )
  for i in g:NoDispBuf
    let name = bufname(i)
    let name = fnamemodify(name, ":t")
    echo i." ".name
  endfor
endfunction

function! OpenFile(pattern)
  if a:pattern[0] == "\""
    let pattern = strpart(a:pattern,1,len(a:pattern)-2)
  else
    let pattern = a:pattern
  endif
  if strpart(pattern, len(pattern)-2, 2) == "\\c"
    exe ":!grep -i \'".strpart(pattern,0,len(pattern)-2)."\' ".g:FileName." > /tmp/aatmp"
  else
    exe ":!grep \'".pattern."\' ".g:FileName." > /tmp/aatmp"
  endif
  let FileLst = readfile('/tmp/aatmp')
  let nooffiles = len(FileLst)
  if nooffiles == 1
    exe ":e ".FileLst[0].""
  elseif nooffiles == 0
    echo "No file found!"
  elseif nooffiles > 1
    call insert(FileLst, "Select a file:")
    for i in range(1,len(FileLst)-1)
      let FileLst[i] = i." ".FileLst[i]
    endfor
    let index = -1
    while !((index >= 0) && (index < len(FileLst)))
      let index = inputlist(FileLst)
      echo "\n\n"
    endwhile
    if ( index > 0 )
      let file = substitute(FileLst[index],'^[0-9]\+ ','','g')
      exe ":e ".file.""
    endif
  endif
endfunction

let g:NoDispBuf = []

function! MyTabLine()
  let l:buflst = []
  for i in range(bufnr('$'))
    if buflisted(i+1) == 1
      let l:buflst += [i+1]
    endif
  endfor

  let s = ''
  let fmtstrlen = 0
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
      let fmtstrlen += 13
    else
      let s .= '%#TabLine#'
      let fmtstrlen += 10
    endif

    let buflist = tabpagebuflist(i+1)
    let winnr = tabpagewinnr(i+1)
    let idx = index(l:buflst, buflist[winnr -1])
    if idx != -1
      let a = remove(l:buflst, idx)
    endif
    let name = bufname(buflist[winnr - 1])
    let name = fnamemodify(name,":t")

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'
    let fmtstrlen += strlen(i+1) + 2
    "let s .= (i+1) . name . ' '
    let s .= name . ' '

  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  let fmtstrlen += 16
  let s .= ' | '

  let winwidth = 0
  for i in range(winnr('$'))
    let winwidth += winwidth(i)
  endfor
  let cnt = 0
  let g:NoDispBuf = []
  let bufNames = []
  let bufnamelen = 0
  let TabLnLen = strlen(s) - fmtstrlen
  for i in l:buflst
    let name = bufname(i)
    let name = fnamemodify(name, ":t")
    "let dispname = " " .  name . i
    let dispname = name . " " . i
    if ( ( strlen(dispname) -strlen(i) + TabLnLen + bufnamelen + 5 ) < winwidth )
      let bufNames += [dispname]
      let bufnamelen += strlen(dispname) -strlen(i)
    else
      let cnt += 1
      let g:NoDispBuf += [i]
    endif
  endfor
  call sort(bufNames)
  let i = 0
  for name in bufNames
    let pos = stridx(name, " ")
    let s .= '%' . strpart(name,pos+1) . 'T'
    if i == 0
      "let s .= '%#Search#'
      let s .= '%#TabLineFill#'
    else
      let s .= '%#StatusLine#'
    endif
    let s .= strpart(name,0,pos+1)
    let i = 1 - i
  endfor

  let s .= '%#TabLineFill#%T'

  if cnt > 0
    let s .= " " . cnt
  endif

  " right-align the label to close the current tab page
  "  if tabpagenr('$') > 1
  "    let s .= '%=%#TabLine#%999XXX'
  "  endif
  let s .= '%=%#TabLine#%999XXX'

  return s
endfunction

:set tabline=%!MyTabLine()
:set showtabline=2

:set cindent
:set modeline
:set autowrite
let $PAGER=''

"----------------------- Abbreiviations ------------------"


"======================= folding =================="
:set foldmethod=manual
":set foldcolumn=4 " extra 4 columns added at front to show details of folding
:command! -nargs=1 ICF exe "normal! mz gg" | call IfCodeFolding(<q-args>) | "normal! `z"
function! IfCodeFolding(pattern)
  let line1 = line(".")
  if matchstr(a:pattern,"#if") != "#if"
    try
      exe "/[^#]".a:pattern.""
    endtry
    exe "normal! ma"
    exe "/{"
  else
    try
      exe "/". a:pattern
    endtry
    exe "normal! ma"
  endif
  exe "normal! %"
  let line2 = line(".")
  if ( line2 > line1)
    exe "normal! zf`a j"
    call IfCodeFolding(a:pattern)
  endif
endfunction

:nmap {} :call CodeFolding()<CR>
function! CodeFolding()
  exe "normal! ma % zf`a"
endfunction

"-------------------vimdiff--------------------"
"set diffopt+=iwhite

set wildmenu
set wildmode=longest:list
set wildignore+=*.o
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
set wildignore+=.DS_Store,.git,.hg,.svn
set wildignore+=*.swp
hi Search cterm=NONE ctermfg=White ctermbg=Blue


function! Restore_search()
	if exists("b:search")
	  let @/ = b:search
	endif
endfunction

autocmd  BufEnter  /tmp/S[a-z][0-9]   : call Restore_search()

function! OpenSearchFile( )
  let FileLst = []
  let SearchString = []
  for [key, value] in items(g:SearchPatterns)
    call add(FileLst, "/tmp/S".g:Base.key)
    call add(SearchString, value)
  endfor
  let nooffiles = len(FileLst)
  if nooffiles == 1
    exe ":e ".FileLst[0].""
  elseif nooffiles > 1
    let PromptLst = []
    for i in range(len(FileLst))
      call add(PromptLst, i." ".FileLst[i]." ".SearchString[i])
    endfor
    call insert(PromptLst, "Select a file:")
    let index = -1
    let index = inputlist(PromptLst)
    exe ":e ".FileLst[index].""
  endif
endfunction

"-------------------Project space------------------"

:command! -nargs=1 SetProject call SetProject(<q-args>)


function! SetProject(pattern)
let &tag = "tags_" . a:pattern
let g:FileName = "files_" . a:pattern . ".txt"
endfunction


function! CProject()
  exe '! find -type f -name "*.d" | xargs cat | ~/.ProjFiles.sh > files.txt'
  exe '! ctags -L files.txt'
endfunction

function! DumpProject()
  exe '! find -type f -not -path "./.git/*" > files.txt '
  exe '! ctags -L files.txt'
endfunction
"------------------- Developing features------------------"
function! Test()
  exe '! clear '
  exe '! find -type f -name "*.d" | xargs cat | ~/.ProjFiles.sh > .files.txt '
  exe '! find -name ".files.txt" '
  exe '! ctags -L .files.txt '
endfunction


function! DeleteBuffers( )
  for buf in getbufinfo({'buflisted':1})
    let name = fnamemodify(buf.name, ":t")
    echo buf.bufnr . " " . name
  endfor
  let files = input("Select files to close: ")

"Use python for string to list with split()
python3 << EOF
import vim
files = vim.eval('files').split()
vim.command("let files = %s" % files)
EOF

  for i in files
    :exe "b " . i
    :exe "bd " . i
  endfor
endfunction

"Disable bell sound
set belloff=all

autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif

function! Formatonsave()
  "let l:formatdiff = 1
  let l:lines = 'all'
  py3f /usr/share/vim/addons/syntax/clang-format.py
endfunction

"autocmd BufWritePre *.c,*.h,*.cc,*.cpp call Formatonsave()

" Vim indent file
" Language:	C++
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2008 Nov 29

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

setlocal cindent
setlocal cino=:0,g0,p0,t0,j1,(0,ws,Ws

let b:undo_indent = "setl cin<"


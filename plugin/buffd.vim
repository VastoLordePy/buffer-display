if exists('g:loaded_buffd') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo
set cpo&vim


command! Buffd lua require'buffd'.buffd()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_buffd = 1

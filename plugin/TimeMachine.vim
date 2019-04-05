scriptencoding utf-8
if exists('g:load_TimeMachine')
    finish
endif
let g:load_TimeMachine = 1

let s:save_cpo = &cpo
set cpo&vim

"nnoremap <silent> <Plug>(TimeMachine) :<C-u>call TimeMachine#TimeMachine()<CR>
nnoremap <silent> <F9> :<C-u>call TimeMachine#TimeMachine()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

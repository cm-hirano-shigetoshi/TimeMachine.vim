scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfer = "~/PublicRepository/fzfer/fzfer.sh"
let s:yaml = expand('<sfile>:p:h') . "/TimeMachine.yml"
let s:temp = tempname()

function! TimeMachine#TimeMachine()
    let file_name = expand('%')
    call writefile([file_name], s:temp)
    let out = system("tput cnorm > /dev/tty; " . s:fzfer . " " . s:yaml . " " . s:temp . " 2>/dev/tty")
    let out = "git show " . out . ":" . system("git rev-parse --show-prefix " . file_name . " | tr -d '\n'")
    let lines = split(system(out), '\n')
    execute("normal ggVGd")
    call append(0, lines)
    redraw!
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


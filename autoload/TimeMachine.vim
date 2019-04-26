scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfer = "~/PublicRepository/fzfer/fzfer.sh"
let s:yaml = expand('<sfile>:p:h') . "/TimeMachine.yml"
let s:temp = tempname()

function! TimeMachine#TimeMachine()
    let file_path = expand('%')
    let out = system("tput cnorm > /dev/tty; " . s:fzfer . " " . s:yaml . " '" . file_path . "' 2>/dev/tty")
    if out == "--"
      let cmd = "cat '" . file_path . "'"
    else
      let cmd = "git show " . out . ":'" . file_path . "'"
    endif
    let lines = split(system(cmd), '\n')
    execute("normal ggVGd")
    call append(0, lines)
    execute("normal gg")
    redraw!
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


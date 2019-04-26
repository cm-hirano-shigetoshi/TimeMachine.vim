scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfer = "~/PublicRepository/fzfer/fzfer.sh"
let s:yaml = expand('<sfile>:p:h') . "/TimeMachine.yml"

function! TimeMachine#TimeMachine()
    let oldpwd = system("pwd")
    let file_dir = expand('%:h')
    execute("cd " . file_dir)
    let filename = expand('%')
    let out = system("tput cnorm > /dev/tty; " . s:fzfer . " " . s:yaml . " '" . filename . "' 2>/dev/tty")
    if len(out) > 0
        if out == "--"
          let cmd = "cat '" . filename . "'"
        else
          let cmd = "git show " . out . ":'" . filename . "'"
        endif
        let lines = split(system(cmd), '\n')
        execute("normal ggVGd")
        call append(0, lines)
        execute("normal gg")
    endif
    execute("cd " . oldpwd)
    redraw!
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


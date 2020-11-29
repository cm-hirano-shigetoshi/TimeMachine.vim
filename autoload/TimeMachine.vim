scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:fzfyml = "fzfyml3 run"
let s:yaml = expand('<sfile>:p:h') . "/TimeMachine.yml"

function! TimeMachine#TimeMachine()
    let s:oldpwd = system("pwd")
    let file_dir = expand('%:h')
    execute("cd " . file_dir)
    let s:filename = expand('%')
    if s:filename[0] != "/"
        let s:filename = "./" . s:filename
    endif
    if has('nvim')
        let s:tmpfile = tempname()
        function! OnFzfExit(job_id, data, exit)
            bd!
            let lines = readfile(s:tmpfile)
            if len(lines) == 1
                let out = readfile(s:tmpfile)[0][:-2]
                if out == "--"
                  let cmd = "cat '" . s:filename . "'"
                else
                  let cmd = "git show " . out . ":'" . s:filename . "'"
                endif
                let lines = split(system(cmd), '\n')
                execute("normal ggVG\"_d")
                call append(0, lines)
                execute("normal gg")
            execute("cd " . s:oldpwd)
            redraw!
            endif
        endfunction
        call delete(s:tmpfile)
        enew
        setlocal statusline=fzf
        setlocal nonumber
        call termopen(s:fzfyml . " " . s:yaml . " '" . s:filename . "' > " . s:tmpfile, {'on_exit': function('OnFzfExit')})
        startinsert
    else
        let out = system("tput cnorm > /dev/tty; " . s:fzfyml . " " . s:yaml . " '" . s:filename . "' 2>/dev/tty")
        if len(out) > 0
            let out = out[:-2]
            if out == "--"
              let cmd = "cat '" . s:filename . "'"
            else
              let cmd = "git show " . out . ":'" . s:filename . "'"
            endif
            let lines = split(system(cmd), '\n')
            execute("normal ggVG\"_d")
            call append(0, lines)
            execute("normal gg")
        endif
        execute("cd " . s:oldpwd)
        redraw!
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


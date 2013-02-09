" ------------------------------------------------------------------------------
" Functions for status bar.  ( Probably only works with newer version of VIM )
" ------------------------------------------------------------------------------
function! CurrSubName()
    let b:subname = ""
    let b:subrecurssion = 0

    " See if this is a Perl file
    let l:firstline = getline(1)

    call GetPerlSubName(line("."))

    return b:subname
endfunction

function! GetPerlSubName(line)
    let l:str = getline(a:line)

    if l:str =~ '^\s*sub\>'
        let l:str = substitute( l:str, ' *{.*', '', '' )
        let l:str = substitute( l:str, '^\s*sub *', ': ', '' )
        let b:subname = l:str
        return 1
    elseif ( l:str =~ '^}' || l:str =~ '^} *#' ) && b:subrecurssion >= 1
        return -1
    elseif a:line > 2
        let b:subrecurssion = b:subrecurssion + 1
        if b:subrecurssion < 190
            call GetPerlSubName(a:line - 1)
        else
            let b:subname = ': <too deep>'
            return -1
        endif
    else
        return -1
    endif
endfunction

autocmd BufWritePost *.pl silent !chmod +x %
autocmd BufWritePost *.t  silent !chmod +x %

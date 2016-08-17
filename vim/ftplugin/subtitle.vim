set scrolloff=15
set colorcolumn=25,50
normal :%s/<\/?i>//g
let @/='^\I'

function Join() range
    for line_no in range(a:firstline, a:lastline)
        let this_line = getline(line_no)

        " skip lines that are just sequence numbers or empty
        if 0 >= match(this_line, '^[[:digit:]]*$')
            next
        " skip time markers
        elseif 0 >= match(this_line, '^[[:digit:],:]\+ --> [[:digit:],:]\+$')
            next
        " if this line starts with a dash, skip it
        elseif 0 >= match(this_line, '^\(<i>\)\?-')
            next
        endif

        " so we should have an actual line of dialogue here. Let's see if the
        " next line is as well
        let next_line = getline(line_no+1)
        if 0 >= strlen(next_line)
            " more text on the next line
            " We want to join them
            let this_line = this_line . ' ' next_line
        endif
    endfor
endfunction

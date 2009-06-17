" Steve's Color Settings for a white background

hi clear
if exists("syntax_on")
  syntax reset
endif
hi Comment              cterm=NONE          ctermfg=DarkGreen        ctermbg=NONE
hi Constant             cterm=NONE          ctermfg=DarkRed          ctermbg=NONE
hi Special              cterm=NONE          ctermfg=Brown            ctermbg=NONE
hi Identifier           cterm=NONE          ctermfg=DarkMagenta      ctermbg=NONE
hi Statement            cterm=NONE          ctermfg=DarkBlue         ctermbg=NONE
hi PreProc              cterm=NONE          ctermfg=DarkCyan         ctermbg=NONE
hi Type                 cterm=NONE          ctermfg=DarkGray         ctermbg=NONE
hi Underlined           cterm=UNDERLINE     ctermfg=DarkMagenta
hi Ignore               cterm=NONE          ctermfg=Black            ctermbg=NONE

hi ErrorMsg             cterm=NONE          ctermfg=White   
hi WarningMsg           cterm=NONE          ctermfg=Cyan
hi ModeMsg              cterm=NONE          ctermfg=Blue
hi MoreMsg              cterm=NONE          ctermfg=Blue
hi Error                cterm=NONE          ctermfg=White            ctermbg=Red

hi Todo                 cterm=NONE          ctermfg=White            ctermbg=Black
hi Cursor               cterm=NONE          ctermfg=Black            ctermbg=White
hi Search               cterm=NONE          ctermfg=Black            ctermbg=DarkYellow
hi IncSearch            cterm=NONE          ctermfg=Black            ctermbg=DarkYellow

hi StatusLineNC         cterm=NONE          ctermfg=DarkRed          ctermbg=Black
hi StatusLine           cterm=NONE          ctermfg=White            ctermbg=Black

hi clear Visual
hi Visual               cterm=NONE          ctermfg=Black            ctermbg=DarkCyan

hi DiffChange           cterm=NONE          ctermfg=Black            ctermbg=DarkGreen
hi DiffText             cterm=NONE          ctermfg=Black            ctermbg=LightGreen
hi DiffAdd              cterm=NONE          ctermfg=Black            ctermbg=Blue
hi DiffDelete           cterm=NONE          ctermfg=Black            ctermbg=Cyan

hi Folded               cterm=NONE          ctermfg=Gray             ctermbg=Black
hi FoldColumn                               ctermfg=Black            ctermbg=Gray


" Steve's Color Settings prairie_wind background

hi clear
if exists("syntax_on")
  syntax reset
endif

hi Normal                                                                 gui=NONE       guifg=#c0c0c0      guibg=#000040

hi Comment      cterm=NONE       ctermfg=Green         ctermbg=NONE       gui=NONE       guifg=Green        guibg=NONE
hi Constant     cterm=NONE       ctermfg=LightRed      ctermbg=NONE       gui=NONE       guifg=LightRed     guibg=NONE
hi Special      cterm=NONE       ctermfg=Brown         ctermbg=NONE       gui=NONE       guifg=Yellow       guibg=NONE
hi Identifier   cterm=NONE       ctermfg=DarkCyan      ctermbg=NONE       gui=NONE       guifg=DarkCyan     guibg=NONE
hi Statement    cterm=NONE       ctermfg=Brown         ctermbg=NONE       gui=NONE       guifg=Yellow       guibg=NONE
hi PreProc      cterm=NONE       ctermfg=Cyan          ctermbg=NONE       gui=NONE       guifg=Cyan         guibg=NONE
hi Type         cterm=NONE       ctermfg=Green         ctermbg=NONE       gui=NONE       guifg=Green        guibg=NONE
hi Underlined   cterm=UNDERLINE  ctermfg=DarkMagenta                      gui=UNDERLINE  guifg=DarkMagenta
hi Ignore       cterm=NONE       ctermfg=White         ctermbg=NONE       gui=NONE       guifg=White        guibg=NONE
hi NonText      cterm=NONE       ctermfg=DarkGrey      ctermbg=NONE       gui=NONE       guifg=DarkGrey     guibg=NONE
hi SpecialKey   cterm=NONE       ctermfg=DarkGrey      ctermbg=NONE       gui=NONE       guifg=DarkGrey     guibg=NONE


hi ErrorMsg     cterm=NONE       ctermfg=White                            gui=NONE       guifg=White
hi WarningMsg   cterm=NONE       ctermfg=Cyan                             gui=NONE       guifg=Cyan
hi ModeMsg      cterm=NONE       ctermfg=Yellow                           gui=NONE       guifg=Yellow
hi MoreMsg      cterm=NONE       ctermfg=Yellow                           gui=NONE       guifg=Yellow
hi Error        cterm=NONE       ctermfg=White         ctermbg=Red        gui=NONE       guifg=White        guibg=Red

hi Todo         cterm=NONE       ctermfg=Black         ctermbg=Yellow     gui=NONE       guifg=Black        guibg=Yellow
hi Cursor       cterm=NONE       ctermfg=Black         ctermbg=White      gui=NONE       guifg=Black        guibg=White
hi Search       cterm=NONE       ctermfg=Black         ctermbg=Yellow     gui=NONE       guifg=Black        guibg=Yellow
hi IncSearch    cterm=NONE       ctermfg=Black         ctermbg=Yellow     gui=NONE       guifg=Black        guibg=Yellow

hi StatusLineNC cterm=NONE       ctermfg=Black         ctermbg=DarkGreen  gui=NONE       guifg=Black        guibg=DarkGreen
hi StatusLine   cterm=NONE       ctermfg=White         ctermbg=DarkBlue   gui=NONE       guifg=White        guibg=DarkBlue

hi clear Visual
hi Visual       cterm=NONE       ctermfg=Black         ctermbg=DarkCyan   gui=NONE       guifg=Black        guibg=Cyan

hi DiffChange   cterm=NONE       ctermfg=Yellow        ctermbg=NONE       gui=NONE       guifg=Yellow       guibg=NONE
hi DiffText     cterm=NONE       ctermfg=Yellow        ctermbg=Grey       gui=NONE       guifg=Black        guibg=Yellow
hi DiffAdd      cterm=NONE       ctermfg=DarkGreen     ctermbg=LightGreen gui=NONE       guifg=Black        guibg=LightGreen
hi DiffDelete   cterm=NONE       ctermfg=DarkRed       ctermbg=LightRed   gui=NONE       guifg=Red          guibg=LightRed

hi Folded       cterm=NONE       ctermfg=Gray          ctermbg=Black      gui=NONE       guifg=Gray         guibg=Black
hi FoldColumn   cterm=NONE       ctermfg=Black         ctermbg=Gray       gui=NONE       guifg=Black        guibg=Gray


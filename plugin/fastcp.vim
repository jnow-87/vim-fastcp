if exists('g:loaded_fastcp') || &compatible
	finish
endif

let g:loaded_fastcp = 1


" dictionary that resolvse special vim keycodes to
" normal mode commands
let fastcp_key_timeout = "400"


" read input character with timeout
function Getchar(timeout_ms)
	let l:sleeped = a:timeout_ms
	while l:sleeped > 0 && getchar(1) == 0
		sleep 50m
		let l:sleeped = l:sleeped - 50 
	endwhile

	return getchar(1)
endfunction

" copy selection into specified register
"
" op	define whether to yank ('y') or cut ('x')
function Copy(op)
	" copy last selection 'gv' into the unnamed register '""'
	" prevent recursive call of 'y' via '!'
	if a:op == 'x'
		normal! gv""x
	else
		normal! gv""y
	endif

	" read char from input
	let l:char = Getchar(g:fastcp_key_timeout)

	" check if valid registers specified
	" if not leave selection in unnamed register
	if l:char >= 97 && l:char <= 122
		let l:char = getchar(0)		" consume the character
		let l:reg = nr2char(l:char)

		" copy content of unnamed register to register
		" specified at input 'l:reg'
		call setreg(l:reg, @")
	endif
endfunction

" paste content from specified buffer
"
" op		define whether to paste in front ('P') or after ('p') cursor
" leave_to	which mode to enter after function, currently only insert mode ('i')
function Paste(op, leave_to)
	" read char
	let l:char = Getchar(g:fastcp_key_timeout)
	let l:reg = nr2char(l:char)

	" copy content of specified register (l:reg) if != 'p'  to unnamed register
	if l:char >= 97 && l:char <= 122 && l:reg != 'p'
		let l:char = getchar(0)
		call setreg('"', getreg(l:reg))
	endif

	" insert content of unnamed register to buffer
	" prevent recursive execution via normal!
	exec 'normal! ""' . a:op

	" change mode
	if a:leave_to == 'i'
		startinsert
	endif
endfunction


vnoremap <silent>y <esc>:call Copy('y')<cr>
vnoremap <silent>x <esc>:call Copy('x')<cr>
nnoremap <silent>p :call Paste('p', '')<cr>
nnoremap <silent>P :call Paste('P', '')<cr>
imap <silent> <C-v> <esc>:call Paste('p', 'i')<cr>

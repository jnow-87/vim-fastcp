let s:timeout = "400m"	" timeout to wait for the optional argument


" copy selection into specified register
"
" op	define whether to yank ('y') or cut ('x')
function Copy(op)
	" read char from input
	exec "sleep " . s:timeout
	let l:char = getchar(1)

	" copy last selection 'gv' into the unnamed register '""'
	" prevent recursive call of 'y' via '!'
	if a:op == 'x'
		normal! gv""x
	else
		normal! gv""y
	endif

	" check if valid registers specified
	" if not leave selection in unnamed register
	if l:char >= 97 && l:char <= 122
		let l:char = getchar()
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
	exe "sleep " . s:timeout
	let l:char = getchar(1)
	let l:reg = nr2char(l:char)

	" copy content of specified register (l:reg) if != 'p'  to unnamed register
	if l:char >= 97 && l:char <= 122 && l:reg != 'p'
		let l:char = getchar()
		call setreg('"', getreg(l:reg))
	endif

	" insert content of unnamed register to buffer
	" prevent recursive execution via normal!
	if a:op == 'p'
		normal! ""p
	else
		normal! ""P
	endif

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


function Testoro()
	sleep 1
	let l:char = getchar(1)

	echo "test: " . l:char . " " . nr2char(l:char)
endfunction

nnoremap <silent>c <esc>:call Testoro()<cr>


"<c-r>=Copy()

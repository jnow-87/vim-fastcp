" dictionary that resolvse special vim keycodes to
" normal mode commands
let s:kmap={}
let s:kmap["\<insert>"] = 'i'
let s:kmap["\<left>"] = 'h'
let s:kmap["\<right>"] = 'l'
let s:kmap["\<up>"] = 'k'
let s:kmap["\<down>"] = 'j'


" function to resolve special vim key codes to
" normal mode commands
function Nr2char(nr)
	" try to find entry in kmap, if no entry available
	" use default nr2char()
	try
		let key = s:kmap[a:nr]
	catch
		let key = nr2char(a:nr)
	endtry

	if key == '' || key == ' '
		return a:nr
	else
		return key
	endif

	return key == '' ? a:nr : key
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
	let l:char = getchar()

	" check if valid registers specified
	" if not leave selection in unnamed register
	if l:char >= 97 && l:char <= 122
		let l:reg = nr2char(l:char)

		" copy content of unnamed register to register
		" specified at input 'l:reg'
		call setreg(l:reg, @")
	else
		" put l:char to prevent eating it
		exec "normal " . Nr2char(l:char)
	endif
endfunction

" paste content from specified buffer
"
" op		define whether to paste in front ('P') or after ('p') cursor
" leave_to	which mode to enter after function, currently only insert mode ('i')
function Paste(op, leave_to)
	" read char
	let l:char = getchar()
	let l:reg = nr2char(l:char)

	" copy content of specified register (l:reg) if != 'p'  to unnamed register
	if l:char >= 97 && l:char <= 122 && l:reg != 'p'
		call setreg('"', getreg(l:reg))
	endif

	" insert content of unnamed register to buffer
	" prevent recursive execution via normal!
	if a:op == 'p'
		normal! ""p
	else
		normal! ""P
	endif

	" if l:char is no valid register put it back
	if l:char < 97 || l:char > 122 || l:reg == 'p'
		exec "normal " . Nr2char(l:char)
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

function Testkey()
	let a = getchar()
	
	echo "nrcode " . a . " key [" . nr2char(a) . "] kmap [" . Nr2char(a) . "]"
endfunction

nmap <silent>c :call Testkey()<cr>

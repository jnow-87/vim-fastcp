if exists('g:loaded_fastcp') || &compatible
	finish
endif

let g:loaded_fastcp = 1


""""
"" global variables
""""
let g:fastcp_key_timeout = get(g:, "fastcp_key_timeout", 400)


""""
"" local functions
""""
"{{{
" \brief	read input character with timeout
function s:getchar(timeout_ms)
	let l:sleeped = a:timeout_ms
	while l:sleeped > 0 && getchar(1) == 0
		sleep 50m
		let l:sleeped = l:sleeped - 50 
	endwhile

	return getchar(1)
endfunction
"}}}

""""
"" main functions
""""
"{{{
" \brief	copy selection into register
"			content is always copied into unnamed register '"'
"			if no target register is specified the content is also copied
"			to 'x' or 'y' register, depending on a:op
"			if a target register is specified the content is copied to it
"
" \param	op		define whether to yank ('y') or to cut ('x')
function s:copy(op)
	" read char from input
	let l:char = s:getchar(g:fastcp_key_timeout)

	" check if valid registers specified
	" if not leave selection in unnamed register
	if l:char >= 97 && l:char <= 122
		let l:char = nr2char(getchar(0))		" consume the character
	elseif a:op == 'x'
		let l:char = 'x'
	else
		let l:char = 'y'
	endif

	" copy last selection 'gv' into registers
	" prevent recursive calls to 'x' or 'y' through '!'
	if a:op == 'x'
		exec 'normal! gv"' . l:char . 'x'
		call setreg('"', getreg(l:char))
	else
		exec 'normal! gv"' . l:char . 'y'
		call setreg('"', getreg(l:char))
	endif
endfunction
"}}}

"{{{
" \brief	paste content from register
"
" \param	op		paste in front ('P') or after ('p') the cursor
" \param	ins		switch to insert mode once done
function s:paste(op, ins)
	" read char
	let l:char = s:getchar(g:fastcp_key_timeout)
	let l:reg = nr2char(l:char)

	" copy content of specified register (l:reg) if != 'p'  to unnamed register
	if l:char >= 97 && l:char <= 122 && l:reg != 'p'
		let l:char = getchar(0)
		call setreg('"', getreg(l:reg))
	endif

	" insert content of unnamed register to buffer
	" prevent recursive execution via normal!
	exec 'normal! ""' . a:op

	" trigger insert mode
	if a:ins
		call feedkeys("\<insert>\<right>")
	endif
endfunction
"}}}


""""
"" mappings
""""
vnoremap <silent> y <esc>:call <sid>copy('y')<cr>
vnoremap <silent> x <esc>:call <sid>copy('x')<cr>
nnoremap <silent> p :call <sid>paste('p', 0)<cr>
nnoremap <silent> P :call <sid>paste('P', 0)<cr>
imap <silent> <c-v> <esc>:call <sid>paste('p', 1)<cr>

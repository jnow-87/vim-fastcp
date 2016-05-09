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
" \brief	read input character with timeout, without consuming it
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
		let l:reg = nr2char(getchar(0))		" consume the character
	elseif a:op == 'x'
		let l:reg = 'x'
	else
		let l:reg = 'y'
	endif

	" copy/cut last selection 'gv' into register l:reg
	" prevent recursive calls to 'x' or 'y' through '!'
	exec 'normal! gv"' . l:reg . a:op
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

	" identify register to be used, prevent 'p' (112) to allow multiple fast paste
	if l:char >= 97 && l:char <= 122 && l:char != 112
		let l:reg = nr2char(getchar(0))
	else
		let l:reg = '"'
	endif

	" insert content of given register, prevent recursive execution via normal!
	exec 'normal! "' . l:reg . a:op

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

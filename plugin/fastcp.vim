if exists('g:loaded_fastcp') || &compatible
	finish
endif

let g:loaded_fastcp = 1

" get own script ID
nmap <c-f11><c-f12><c-f13> <sid>
let s:sid = "<SNR>" . maparg("<c-f11><c-f12><c-f13>", "n", 0, 1).sid . "_"
nunmap <c-f11><c-f12><c-f13>


""""
"" global variables
""""
"{{{
let g:fastcp_map_timeout = get(g:, "fastcp_map_timeout", 400)
let g:fastcp_map_copy = get(g:, "fastcp_map_copy", "y")
let g:fastcp_map_cut = get(g:, "fastcp_map_cut", "x")
let g:fastcp_map_paste_front = get(g:, "fastcp_map_paste_front", "P")
let g:fastcp_map_paste_back = get(g:, "fastcp_map_paste_back", "p")
let g:fastcp_map_paste_i = get(g:, "fastcp_map_paste_i", "<c-v>")
"}}}

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
"" global functions
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
	let l:char = s:getchar(g:fastcp_map_timeout)

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
	let l:char = s:getchar(g:fastcp_map_timeout)

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
"{{{
call util#map#v(g:fastcp_map_copy, '<esc>:call ' . s:sid . 'copy("y")<cr>', '')
call util#map#v(g:fastcp_map_cut, '<esc>:call ' . s:sid . 'copy("x")<cr>', '')
call util#map#n(g:fastcp_map_paste_front, ':call ' . s:sid . 'paste("P", 0)<cr>', '')
call util#map#n(g:fastcp_map_paste_back, ':call ' . s:sid . 'paste("p", 0)<cr>', '')
call util#map#i(g:fastcp_map_paste_i, "<esc>:call " . s:sid . "paste('p', 1)<cr>", "noescape noinsert")
"}}}

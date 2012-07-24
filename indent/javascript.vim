" Vim indent file
" Language:		Javascript
" Maintainer:		Hidden <zzdhidden@gmail.com>
" URL:			https://github.com/zzdhidden/vim-javascript-indent
" Version:              0.1.0
" Last Change:          2011-12-2
" Acknowledgement:      Based on http://github.com/pangloss/vim-javascript

" 0. Initialization {{{1
" =================

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal nosmartindent

" Now, set up our indentation expression and keys that trigger it.
setlocal indentexpr=GetJavascriptIndent()
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,0.,0+,,

" Only define the function once.
if exists("*GetJavascriptIndent")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

" 1. Variables {{{1
" ============

" Regex of syntax group names that are or delimit string or are comments.
let s:syng_strcom = 'javaScript\%(String\|RegexpString\|CommentTodo\|LineComment\|Comment\|DocComment\)'

" Regex of syntax group names that are strings.
let s:syng_string = 'javaScript\%(RegexpString\)'

" Regex of syntax group names that are strings or documentation.
let s:syng_stringdoc = 'javaScriptDocComment\|javaScriptComment'

" Expression used to check whether we should skip a match with searchpair().
let s:skip_expr = "synIDattr(synID(line('.'),col('.'),1),'name') =~ '".s:syng_strcom."'"

let s:line_term = '\s*\%(\%(\/\/\).*\)\=$'

" Regex prefix line block
let s:line_block_pre_regex = '^\s*\%([\\*+/.,:]\|\W[|&?]\|||\|&&\)'
let s:line_block_suf_regex = '\%([\\*+/.,:]\|\W[|&?]\|||\|&&\)' . s:line_term

" Regex suffix line block

let s:one_line_scope_regex = '\<\%(if\|else\|for\|while\)\>[^{;]*' . s:line_term

" Regex that defines start blocks.
let s:block_start_regex = '\%({\|[\|(\)\s*' . s:line_term

" Regex that defines end blocks.
let s:block_end_regex = '^\s*[]})]'


" 2. Auxiliary Functions {{{1
" ======================

" Check if the character at lnum:col is inside a string, comment, or is ascii.
function s:IsInStringOrComment(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_strcom
endfunction

" Check if the character at lnum:col is inside a string.
function s:IsInString(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_string
endfunction

" Check if the character at lnum:col is inside a string or documentation.
function s:IsInStringOrDocumentation(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_stringdoc
endfunction

" Find line above 'lnum' that isn't empty, in a comment, or in a string.
function s:PrevNonBlankNonString(lnum)
	let in_block = 0
	let lnum = prevnonblank(a:lnum)
	while lnum > 0
		" Go in and out of blocks comments as necessary.
		" If the line isn't empty (with opt. comment) or in a string, end search.
		let line = getline(lnum)
		if line =~ '/\*'
			if in_block
				let in_block = 0
			else
				break
			endif
		elseif !in_block && line =~ '\*/'
			let in_block = 1
		elseif !in_block && line !~ '^\s*\%(//\).*$' && !(s:IsInStringOrComment(lnum, 1) && s:IsInStringOrComment(lnum, strlen(line)))
			break
		endif
		let lnum = prevnonblank(lnum - 1)
	endwhile
	return lnum
endfunction

" Match line not comment...

function s:Match(lnum, regex)
	let col = match(getline(a:lnum), a:regex) + 1
	return col > 0 && !s:IsInStringOrComment(a:lnum, col) ? col : 0
endfunction

" Find the start line of line block.
function s:GetLineBlockStart(lnum)
	" Start on the line we're at and use its indent.
	let msl = -1
	" let lnum = s:PrevNonBlankNonString(a:lnum)
	let lnum = a:lnum
	let commaline = ""
	let notcomma = 0
	while lnum > 0
		" If we have a continuation line, or we're in a string, use line as MSL.
		" Otherwise, terminate search as we have found our MSL already.
		let line = getline(lnum)
		let col = match(line, s:line_block_pre_regex) + 1

		let lnum2 = s:PrevNonBlankNonString(lnum - 1)
		let line2 = getline(lnum2)
		let col2 = match(line2, s:line_block_suf_regex) + 1

		" call confirm("col: " . col . ":" . lnum . ":" . line[col] )
		if (col > 0 && !s:IsInStringOrComment(lnum, col)) || (col2 > 0 && !s:IsInStringOrComment(lnum2, col2)) || s:IsInString(lnum, strlen(line))
			" call confirm("col: " . col . " col2:" . col2)
			" , only indent after var..
			if (col > 0 && (match(line, '^\s*,') + 1) > 0) || (col2 > 0 && (match(line2, ',' . s:line_term) + 1) > 0)
				if !notcomma
					" call confirm("l: " . lnum)
					let commaline = line2
				end
				" call confirm("ok: " . commaline . ":" . line2)
			else
				let notcomma = 1
			endif
			let msl = lnum2
			let lnum = lnum2
		else
			"Skip block
			let lnum2 = s:GetBlockStart(lnum)
			if lnum2 > 0 
				let lnum = lnum2
				if msl > 0
					let msl = lnum2
				endif
			else
				if strlen(commaline) && match(commaline, '^\s*var') == -1
					" call confirm("ok3: ")
					return -1
				endif
				break
			endif
		endif
	endwhile
	return msl
endfunction

" Find the start line of one line scope.
function s:GetLineScopeStart(lnum)
	let cnum = -1
	let lnum = s:PrevNonBlankNonString(a:lnum - 1)
	while lnum > 0
		" If we have a continuation line, or we're in a string, use line as MSL.
		" Otherwise, terminate search as we have found our MSL already.
		if s:Match(lnum, s:one_line_scope_regex)
			let cnum = lnum
			let lnum = s:PrevNonBlankNonString(lnum - 1)
		else
			break
		endif
	endwhile
	return cnum
endfunction

" Find the start line of line block.
function s:GetBlockStart(lnum)
	let lnum = a:lnum
	let line = getline(lnum)
	let col = matchend(line, s:block_end_regex)
	if col > 0 && !s:IsInStringOrComment(lnum, col)
		call cursor(lnum, col)
		let bs = strpart('(){}[]', stridx(')}]', line[col - 1]) * 2, 2)
		if searchpair(escape(bs[0], '\['), '', bs[1], 'bW', s:skip_expr) > 0
			let lnum = line('.')
		endif
		return lnum
	else
		return -1
	endif
endfunction

function s:LeftComma(lnum)
	let cur = match(getline(a:lnum), '^\s*,') + 1 > 0
	let last = match(getline(s:PrevNonBlankNonString(a:lnum - 1)), '^\s*,') + 1 > 0
	return cur && !last ? 2 : ( last && !cur ? -2 : 0)
endfunction

" 3. GetJavascriptIndent Function {{{1
" =========================

function GetJavascriptIndent()
	" 3.1. Setup {{{2
	" ----------

	" Set up variables for restoring position in file.  Could use v:lnum here.
	let vcol = col('.')

	" 3.2. Work on the current line {{{2
	" -----------------------------
	"

	let line = getline(v:lnum)
	let ind = -1

	" Close block.
	" If we got a closing bracket on an empty line, find its match and indent
	" according to it.  For parentheses we indent to its column - 1, for the
	" others we indent to the containing line's MSL's level.  Return -1 if fail.
	let cnum = s:GetBlockStart(v:lnum)
	if cnum > 0
		" Right indent comma
		return indent(cnum) + ((match(getline(cnum), '^\s*,') + 1 > 0) ? 2: 0)
	endif

	" If we have a /* set indent to first column.
	if match(line, '^\s*\%(/\*\)') != -1 && s:IsInStringOrDocumentation(v:lnum, matchend(line, '^\s*') + 1)
		return indent('.')
	endif

	" If we are in a multi-line string or line-comment, indent by last+1
	let lnum = v:lnum
	if s:IsInStringOrDocumentation(lnum, matchend(line, '^\s*') + 1)
		let cnum = prevnonblank(lnum - 1)
		while(cnum > 0)
			if s:IsInStringOrDocumentation(cnum, matchend(getline(cnum), '^\s*') + 1)
				let lnum = cnum
				let cnum = prevnonblank(cnum - 1)
			else
				break
			endif
		endwhile
		"call confirm("l: " . cnum . ":" . line('.'))
		return indent(lnum) + 1
	endif

	" Indent line block...
	let cnum = s:GetLineBlockStart(v:lnum)
	if cnum > 0 && cnum != v:lnum
		" call confirm("r:" . cnum)
		" Left indent comma
		return  indent(cnum) + &sw - ((match(line, '^\s*,') + 1 > 0) ? 2: 0)
	endif

	" }}}2
	"
	"
	" Get the current line.
	" 3.3. Work on the previous line. {{{2
	" -------------------------------

	" Find a non-blank, non-multi-line string line above the current line.
	let lnum = s:PrevNonBlankNonString(v:lnum - 1)

	" Comment above
	if s:IsInStringOrDocumentation(prevnonblank(v:lnum - 1), matchend(line, '^\s*') + 1)
		return indent(prevnonblank(v:lnum - 1)) - 1
	endif
	" If the line is empty and inside a string, use the previous line.
	if line =~ '^\s*$' && lnum != prevnonblank(v:lnum - 1)
		return indent(prevnonblank(v:lnum))
	endif

	" At the start of the file use zero indent.
	if lnum == 0
		return 0
	endif

	" Set up variables for current line.
	let line = getline(lnum)
	let ind = indent(lnum)

	" If the previous line ended with a block opening, or a one line scope, add a level of indent.
	if s:Match(lnum, s:block_start_regex) || s:Match(lnum, s:one_line_scope_regex)
		return ind + &sw
	endif

	" Close line block...
	let cnum = s:GetLineBlockStart(lnum)
	if cnum > 0
		" call confirm("col: " . lnum . ":" . cnum)
		let nnum = s:GetLineScopeStart(cnum)
		if nnum > 0
			return indent(nnum)
		endif
		return indent(cnum)
	end

	" Close one line scope...
	let nnum = s:GetLineScopeStart(lnum)
	if nnum > 0
		return indent(nnum)
	endif
	" Left indent comma
	let cur = match(getline(v:lnum), '^\s*,') + 1 > 0
	let last = match(line, '^\s*,') + 1 > 0
	return ind - (cur && !last ? 2 : ( last && !cur ? -2 : 0))

endfunction

" }}}1

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=4 ts=4 noet:


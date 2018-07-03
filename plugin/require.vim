" require.vim           require vim easy
" Author:    gu.fan at https://github.com/gu-fan
" License:   wtfpl at http://sam.zoy.org/wtfpl/COPYING.

set sua=.vim,index.vim

let g:require = {}
let g:export= {}

" contains all the module name
let s:modules = {}
" contain all the module exported values
let s:exports = {}
" indicate current main
let s:_main = ''

let g:require.user_path = ['~/.vim/plugged/']
let s:user_path = []

fun! g:require.resolve(module, sfile)
    let module = a:module
    let sfile = a:sfile
    " normalize filename with '/', for mac
    let m = fnamemodify(module, ':gs?\\?/?')
    let p = fnamemodify(sfile, ':h:gs?\\?/?')
    let _sep = '/'
    let tail = fnamemodify(module, ':t:r:gs?\\?/?')
    let _files = [
            \ p ._sep. m .'.vim',
            \ p ._sep. m ._sep. tail.'.vim',
            \ p ._sep. m ._sep. 'index.vim',
            \ $VIMRUNTIME ._sep. m .'.vim',
            \ $VIMRUNTIME ._sep. 'plugin' . _sep . m .'.vim',
            \ ]

    let user_path = map(copy(s:user_path), "v:val . m . '.vim'")
    call extend(_files, user_path, 1)
    let user_path2 = map(copy(s:user_path), "v:val . m . _sep.'index.vim'")
    call extend(_files, user_path2, 1)
    " echom string(_files)

    call filter(_files, 'filereadable(v:val)')
    return _files
endfun


fun! g:require.source(files)

    let f = resolve(a:files[0])

    " NOTE: Avoid recursive chaining
    if !exists("s:modules[f]")
        let s:modules[f] = {}
    else
        if exists('s:exports[f]')
            return s:exports[f]
        else
            " echom "[require.vim] no exported value at ". f
            return -1
        endif
    endif

    if s:_main == ''
        let s:_main = f
        let s:modules[f].chain = {}
        let s:modules[f].chain[f] = 1
    else
        " AVOID recursive require chaining
        let s:modules[s:_main].chain[f] = 1
    endif

    exe  'so '.f

    if s:_main == f
        let s:_main = ''
    endif

    if exists('s:exports[f]')
        return s:exports[f]
    else
        " echom "[require.vim] no exported value at ". f
        return -1
    endif
    
endfun

fun! s:_require(sfile, slnum, module)

    let module = a:module
    let slnum = a:slnum
    let sfile = a:sfile

    " STEP1: generate possible paths
    let _files = g:require.resolve(module, sfile)


    " STEP2: source the valid file.
    if !empty(_files)
        return g:require.source(_files)
    else
        " NOTE: we can use setqflist or cex to set error list.
        echohl Error
        echom  "[require.vim] module '" . m . "' not found at ".a:sfile. ":". slnum
        echom a:sfile . ":" .  module
        echohl normal
        return -2
    endif
    
endfun

function! s:require(sfile,slnum, module)

    if type(a:module) == v:t_list
        for mod in a:module
            call s:_require(a:sfile, a:slnum, mod)
        endfor
    elseif type(a:module) == v:t_dict
        for mod in values(a:module)
            call s:_require(a:sfile, a:slnum, mod)
        endfor
    elseif type(a:module) == v:t_string
        call s:_require(a:sfile, a:slnum, a:module)
    elseif type(a:module) == v:t_number
        call s:_require(a:sfile, a:slnum, a:module)
    else
        throw "unexpcted type of module " . string(a:module)
    endif

endfun


function! s:export(val, sfile, bang) abort
    let bang = a:bang == '!' ? 1 : 0
 
    let f = resolve(fnamemodify(a:sfile, ':p:gs?\\?/?'))

    if !bang && exists('s:exports[f]')
        " echom "[require.vim]  ". f . " already exported"
    else
        let s:exports[f] = a:val
    endif

endfunction

function! g:export.at(val, sfile, ...)
    call s:export(a:val, a:sfile, 1)
endfunction

function! g:require.at(module, sfile, ... )
    return s:_require(a:sfile, expand('<slnum>'), a:module)
endfunction

let g:export.values = s:exports
let g:require.modules = s:modules


" normalize user paths 
fun! s:trim_slash(key, path)
    return expand(fnamemodify(a:path, ':gs?\\?/?'))
endfun

fun! s:init()
    let user_path = exists("g:require.user_path") ? g:require.user_path : []
    let s:user_path  = map(user_path, function("s:trim_slash"))
endfun
call s:init()

com! -nargs=1 Require call s:require(expand('<sfile>:p'), expand('<slnum>'),<args>)
com! -nargs=* -bang Export call s:export(<args>, expand('<sfile>:p'), "<bang>")

com! -nargs=0 ClearRequireCache let s:modules = {} | let s:exports = {}

" vim:fdm=indent

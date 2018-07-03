fun! s:test()

    " require one module
    Require 'global'
    echom GlobalFunc() == "global"


    " require multiple modules
    Require ['lib/a', 'lib/b', './c', 'simpleterm.vim/test/require']
    echom GlobalFuncA() == "global a"
    echom GlobalFuncB() == "global b"
    echom GlobalFuncC() == "global c"
    echom GlobalFuncTerm() == "simple terminal"


    let spath = expand("<sfile>:p")

    " require plain value
    let plain = g:require.at("plain", spath)
    echom plain.a == "1"
    echom type(plain.dic.fun) == v:t_func


    " require private value
    let private = g:require.at("private", spath)
    echom private[1] == 2
    echom type(private[4].fun) == v:t_func
endfun


call s:test()

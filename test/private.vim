let s:b = {"a":1,"b":2}
fun! s:b.fun() dict
    return 3
endfun
let s:k = [1,2,3,4, s:b]

call export.at(s:k, expand("<sfile>:p"))

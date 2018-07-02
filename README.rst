require.vim
===========

Require vim in js way

Install
-------


``Plug 'gu-fan/require.vim'``


Useage
------


``Export`` a module 

 .. code:: vim   
     
     " test_export.vim
     let k = {a:1}

     function k.msg()
         return 'private msg'
     endfun

     function GlobalFunc()
         return 'Global'
     endfun


     Export k


``Require`` or ``Import`` a module

 .. code:: vim   
     
     " test_import.vim
 
     Require test_export
     let msg = GlobalFunc()  " Global

``export.at`` a private module

 .. code:: vim   
     
     " test_private.vim
 
     let s:private = {a:1}
     call export.at(s:private, expand("<sfile>:p")) " should pass the path to resolve the name

``require.at`` a module

 .. code:: vim   
     
     " test_import.vim
 
     let k = require.at('test_private', expand("<sfile>:p")) " should pass the path to resolve the name
     echo k           " {a:1}



----

By default, when require, 

it will first search module in relative paths,

if not found, then search the dot.env path

then it will search the &runtimepath

with file pattern match 'test_export.vim' 'test_export/index.vim' 'plugin/test_export.vim'

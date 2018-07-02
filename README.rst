require.vim
===========

Require vim in js way

Install
-------


    Plug 'gu-fan/require.vim'


Useage
------


``Export`` a module 

 .. code:: vim   
     
     " test_export.vim
     let k = {a:1}

     function ECHO()
         return 'export'
     endfun


     Export k


``Require`` or ``Import`` a module

 .. code:: vim   
     
     " test_import.vim
 
     Require test_export
     let msg = ECHO()  " export

     
``require.at``

 .. code:: vim   
     
     " test_import.vim
 
     let k = require.at('test_export')
     echo k     " {a:1}



----

By default, when require, 

it will first search module in relative paths,

if not found, then search the dot.env path

then it will search the &runtimepath

with file pattern match 'test_export.vim' 'test_export/index.vim' 'plugin/test_export.vim'

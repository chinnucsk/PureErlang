-module(pureerlang_test_controller, [Req]).
-compile(export_all).
 
hello('GET', []) ->
    {output, "<strong>Rocky says hello!</strong>"}.
-module(category, [Id, Name, Description]).
-compile(export_all).
 
validation_tests() ->
    [{fun() -> length(Name) > 0 end, "Category must have a name."}].
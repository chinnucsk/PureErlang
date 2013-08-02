-module(pureerlang_categories_controller, [Req]).
-compile(export_all).
 
index('GET', []) ->
    Categories = boss_db:find(category, []),
    {ok, [{categories, Categories}]}.

notfound('GET', []) -> ok;
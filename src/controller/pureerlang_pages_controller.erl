-module(pureerlang_pages_controller, [Req]).
-compile(export_all).
 
index('GET', []) ->
    Pages = boss_db:find(page, []),
    {ok, [{pages, Pages}]}.

%% @doc Handles rendering the new wiki page view which is empty by default
create('GET', []) -> ok;

%% @doc Handles POST data for creating pages
create('POST', []) ->
    Title = Req:post_param("page_title"),
    Text = Req:post_param("page_text"),
    NewPage = page:new(id, Title, Text),
    case NewPage:save() of
        {ok, SavedPage} ->   {redirect, [{action, "view"}, {id, SavedPage:id()}]};
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {new_page, NewPage}]}
    end.

%% @doc display a specific page
view('GET', [Id]) ->
    case boss_db:find(Id) of
        {error, Reason} -> {redirect, [{action, "create"}]}; %% TODO: Redirect to error page
        undefined -> {redirect, [{action, "create"}]}; % When you visit /view/NotExistentPage the requested Page doesn't exist, we redirect the client to the edit Page so the content may be created
        ExistingPage ->
            % Replace all [page-id] with links
            % TODO: There has to be a better way
            StartHrefs = re:replace(ExistingPage:page_text(), "\\[\\w*\-*[0-9]*", "<a href='/pages/view/&'>&", [global, {return, list}]),
            ClosedHrefs = re:replace(StartHrefs, "\\]", "</a>", [global, {return, list}]),
            CleanedUp = re:replace(ClosedHrefs, <<"\\[">>, "", [global, {return, list}]),
            {ok, [{page, ExistingPage}, {cleaned, CleanedUp}]}
    end.

%% @doc edit a saved page
edit('GET', [Id]) ->
    ExistingPage = boss_db:find(Id),
    {ok, [{page, ExistingPage}]};  

%% @doc Updates the wiki page from the Edit view's POST information
edit('POST', []) ->
    Id = Req:post_param("page_id"),
    Title = Req:post_param("page_title"),
    Text = Req:post_param("page_text"),
    ExistingPage = boss_db:find(Id),
    UpdatedPage = ExistingPage:set( [{page_text, Text}, {page_title, Title}] ),
    case UpdatedPage:save() of
        {ok, Saved} ->   {redirect, [{action, "view"}, {id, Id}]}; % Redirect to the updated page
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {page, UpdatedPage}]}
    end.

notfound('GET', []) -> ok;
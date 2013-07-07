-module(PureErlang_pages_controller, [Req]).
-compile(export_all).
 
index('GET', []) ->
    Pages = boss_db:find(page, []),
    {ok, [{pages, Pages}]}.

%% @doc Handles rendering the new wiki page view which is empty by default
create('GET', []) -> ok;

%% @doc Handles POST data of form submission from new wiki page
create('POST', []) ->
    Title = Req:post_param("page_title"),
    Text = Req:post_param("page_text"),
    NewWikiPage = page:new(id, Title, Text),
    case NewWikiPage:save() of
        {ok, SavedWikiPage} ->   {redirect, [{action, "view"}, {id, SavedWikiPage:id()}]};
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {new_page, NewWikiPage}]}
    end.

%% @doc display a specific wiki page
view('GET', [Id]) ->
    case boss_db:find(Id) of
        {error, Reason} -> {redirect, [{action, "create"}]}; %% TODO: Redirect to error page
        undefined -> {redirect, [{action, "create"}]}; % When you visit /view/NotExistentPage the requested Page doesn't exist, we redirect the client to the edit Page so the content may be created
        ExistingWikiPage ->
            % Replace all [page-id] with links
            % TODO: There has to be a better way
            StartHrefs = re:replace(ExistingWikiPage:page_text(), "\\[\\w*\-*[0-9]*", "<a href='/pages/view/&'>&", [global, {return, list}]),
            ClosedHrefs = re:replace(StartHrefs, "\\]", "</a>", [global, {return, list}]),
            CleanedUp = re:replace(ClosedHrefs, <<"\\[">>, "", [global, {return, list}]),
            {ok, [{page, ExistingWikiPage}, {cleaned, CleanedUp}]}
    end.

%% @doc Fetch the existing wiki and show the edit page
edit('GET', [Id]) ->
    ExistingWikiPage = boss_db:find(Id),
    {ok, [{page, ExistingWikiPage}]};  

%% @doc Updates the wiki page from the Edit view's POST information
edit('POST', []) ->
    Id = Req:post_param("page_id"),
    Title = Req:post_param("page_title"),
    Text = Req:post_param("page_text"),
    ExistingWikiPage = boss_db:find(Id),
    UpdatedWikiPage = ExistingWikiPage:set( [{page_text, Text}, {page_title, Title}] ),
    case UpdatedWikiPage:save() of
        {ok, SavedWiki} ->   {redirect, [{action, "view"}, {id, Id}]}; % Redirect to the updated page
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {page, UpdatedWikiPage}]}
    end.

notfound('GET', []) -> ok;
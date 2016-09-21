-module({{appname}}).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% dev functions
-export([dev/0]).
-export([routes/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile(routes()),
    {ok, Port} = application:get_env(http_port),
    {ok, _} = cowboy:start_http(
                  {{appname}}_http_listener, %listener name
                  100,              %number of acceptors
                  [{port, Port}],
                  [{env, [{dispatch, Dispatch}]}]),
    {{appname}}_sup:start_link().

stop(_State) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================
routes() ->
    StaticOpts = [{mimetypes, cow_mimetypes, all}],
    Domain = '_', %match any domain
    Urls = [{"/service/greet", {{appname}}_handler, []}
           ,{"/", cowboy_static, {file, "frontend/index.html", StaticOpts}}
           ,{"/[...]", cowboy_static, {dir, "frontend", StaticOpts}}
           ],
    [{Domain, Urls}].

%% ========================================================
%% Development-only functions
%% ========================================================
dev() ->
    Apps = [crypto, ranch, cowlib, cowboy, {{appname}}],
    [application:ensure_started(App) || App <- Apps],
    sync:go(),
    sync:onsync(fun dev_reroute/1),
    io:format("app {{appname}} ready~n").

dev_reroute([?MODULE|_]) ->
    io:format('recompiling routes~n'),
    Dispatch = cowboy_router:compile(?MODULE:routes()),
    cowboy:set_env({{appname}}_http_listener, dispatch, Dispatch),
    ?MODULE:dev();
dev_reroute([_|Rest]) -> dev_reroute(Rest);
dev_reroute([])       -> ok.

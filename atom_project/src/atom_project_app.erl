-module(atom_project_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    atom_project_sup:start_link().

stop(_State) ->
    ok.

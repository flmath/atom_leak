-module(atom_project_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [#{id => atom_server,
                    start => {atom_server, start_link, []},
                    restart => permanent,
                    shutdown => 5000,
                    type => worker,
                    modules => [atom_server]}],
    {ok, {SupFlags, ChildSpecs}}.

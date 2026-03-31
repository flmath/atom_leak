-module(atom_server_SUITE).
-include_lib("common_test/include/ct.hrl").
-export([all/0, init_per_suite/1, end_per_suite/1]).
-export([test_atom_leak/1]).

all() ->
    [test_atom_leak].

init_per_suite(Config) ->
    %% Ensure distributed node
    os:cmd("epmd -daemon"),
    NodeResult = case net_kernel:start(['server', shortnames]) of
        {ok, _} -> ok;
        {error, {already_started, _}} -> ok;
        Error -> Error
    end,
    ct:log("net_kernel:start result: ~p", [NodeResult]),
    ct:log("Current node: ~p", [node()]),
    erlang:set_cookie(node(), 'test_cookie'),
    
    ServerResult = atom_server:start(),
    ct:log("atom_server:start result: ~p", [ServerResult]),
    {ok, _} = ServerResult,
    Config.

end_per_suite(_Config) ->
    atom_server:stop(),
    net_kernel:stop(),
    ok.

test_atom_leak(_Config) ->
    ServerNode = node(),
    Script = "/workspace/atom_project/scripts/ping_server.sh",
    
    %% Warm-up
    os:cmd(lists:flatten(io_lib:format("bash ~s warm_up ~s", [Script, ServerNode]))),
    timer:sleep(2000),

    {atoms_used, N1} = atom_server:how_many_atoms(ServerNode),
    ct:log("Initial atoms (after warm-up): ~p", [N1]),

    Monitors = [begin 
                %% Slight delay to avoid process spawning limit or port exhaustion
                timer:sleep(100),
                {_Pid, Mon} = spawn_monitor(fun() -> 
                    Cmd = lists:flatten(io_lib:format("bash ~s ~p ~s", [Script, I, ServerNode])),
                    Result = os:cmd(Cmd),
                    case Result of
                        [] -> ok;
                        _ -> ct:log("Node ~p output: ~s", [I, Result])
                    end
                end),
                Mon
            end || I <- lists:seq(1, 50)],

    %% Wait for all to finish
    [receive {'DOWN', Mon, process, _Pid, normal} -> ok after 60000 -> ct:fail(timeout) end || Mon <- Monitors],
    
    %% Delay to ensure all distribution protocols finished
    timer:sleep(5000),

    {atoms_used, N2} = atom_server:how_many_atoms(ServerNode),
    NodesReached = atom_server:how_many_nodes(ServerNode),
    
    ct:log("Final atoms: ~p", [N2]),
    ct:log("Diff: ~p", [N2 - N1]),
    ct:log("Nodes reached: ~p", [NodesReached]),
    
    Diff = N2 - N1,
    if 
        Diff == 50 -> ok;
        true -> ct:fail({wrong_atom_count, Diff, nodes_reached, NodesReached})
    end.

-module(atom_server).
-behaviour(gen_server).

%% API
-export([start/0, start_link/0, stop/0, ping/1, how_many_atoms/1, how_many_nodes/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

start() ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
    gen_server:call(?SERVER, stop).

ping(Node) ->
    gen_server:call({?SERVER, Node}, ping).

how_many_atoms(Node) ->
    gen_server:call({?SERVER, Node}, how_many_atoms).

how_many_nodes(Node) ->
    gen_server:call({?SERVER, Node}, how_many_nodes).

init([]) ->
    {ok, #{nodes => sets:new()}}.

handle_call(ping, {FromPid, _Tag}, State) ->
    Node = node(FromPid),
    Nodes = maps:get(nodes, State),
    {reply, pong, State#{nodes => sets:add_element(Node, Nodes)}};
handle_call(how_many_atoms, _From, State) ->
    {reply, {atoms_used, erlang:system_info(atom_count)}, State};
handle_call(how_many_nodes, _From, State) ->
    {reply, sets:size(maps:get(nodes, State)), State};
handle_call(stop, _From, State) ->
    {stop, normal, ok, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

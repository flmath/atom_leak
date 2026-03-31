#!/bin/bash
INDEX=$1
SERVER_NODE=$2
TS=$(date +%s%N)
NODE_NAME="test_node_${INDEX}_${TS}"
COOKIE="test_cookie"

erl -sname ${NODE_NAME} -setcookie ${COOKIE} -noshell -eval "
    case net_adm:ping('${SERVER_NODE}') of
        pong ->
            case gen_server:call({atom_server, '${SERVER_NODE}'}, ping) of
                pong -> halt(0);
                _ -> halt(1)
            end;
        _ -> halt(2)
    end.
"

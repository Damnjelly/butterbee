-module(port_finder).

-export([new_port/0]).

new_port() ->
    case gen_tcp:listen(0, [{ip, {127, 0, 0, 1}}]) of
        {ok, ListenSocket} ->
            case inet:sockname(ListenSocket) of
                {ok, {_, Port}} ->
                    gen_tcp:close(ListenSocket),
                    {ok, Port};
                {error, Reason} ->
                    gen_tcp:close(ListenSocket),
                    {error, {bind_error, atom_to_binary(Reason)}}
            end;
        {error, Reason} ->
            {error, {socket_error, atom_to_binary(Reason)}}
    end.

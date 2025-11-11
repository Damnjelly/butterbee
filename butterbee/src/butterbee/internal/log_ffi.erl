%% log_ffi.erl
-module(log_ffi).

-export([add_primary_filters/1, add_primary_inspect/0]).

%% Public: accept a list of Gleam strings (binaries) or Erlang strings
add_primary_filters(Patterns) when is_list(Patterns) ->
    lists:foreach(fun(P) -> add_primary_filter(P) end, Patterns),
    ok.

%% Accept binary or list pattern
add_primary_filter(P) when is_list(P) ->
    add_primary_filter(list_to_binary(P));
add_primary_filter(PBin) when is_binary(PBin) ->
    Pattern = binary_to_list(PBin),
    FilterId = list_to_atom("gleam_filter_" ++ integer_to_list(erlang:phash2(Pattern))),

    %% Filter fun must be arity 2: fun(LogEvent, Extra) -> stop | ignore | LogEvent
    Fun = fun(LogEvent, _Extra) ->
             MsgStr = normalize_msg(LogEvent),
             %% re:run returns {match, Captures} | nomatch | {error, Reason}
             case catch re:run(MsgStr, Pattern, [{capture, none}]) of
                 {match, _} -> stop;
                 match -> stop;       %% some versions may return 'match'
                 nomatch -> LogEvent;
                 {error, _} -> LogEvent;
                 {'EXIT', _} -> LogEvent
             end
          end,

    %% Remove previous filter with same id (safe) and add new one
    catch logger:remove_primary_filter(FilterId),
    %% filter arg we don't need, give an empty list
    ok = logger:add_primary_filter(FilterId, {Fun, []}),
    ok.

%% Debug helper: install a primary filter that prints every LogEvent to stdout.
%% Use this to inspect what the runtime actually sends for your failing logs.
add_primary_inspect() ->
    FilterId = gleam_inspect,
    Fun = fun(LogEvent, _Extra) ->
             io:format("LOGGER EVENT: ~p~n", [LogEvent]),
             LogEvent
          end,
    catch logger:remove_primary_filter(FilterId),
    ok = logger:add_primary_filter(FilterId, {Fun, []}),
    ok.

%% Normalize the message into printable string (covers common shapes)
normalize_msg(#{msg := {string, Str}}) when is_list(Str) ->
    Str;
normalize_msg(#{msg := {string, Bin}}) when is_binary(Bin) ->
    binary_to_list(Bin);
normalize_msg(#{msg := {report, Report}}) ->
    io_lib:format("~p", [Report]);
normalize_msg(#{msg := {Fmt, Args}}) ->
    io_lib:format(Fmt, Args);
normalize_msg({_, Msg, _}) when is_list(Msg) ->
    Msg;     %% legacy tuple style
normalize_msg({_, Msg, _}) when is_binary(Msg) ->
    binary_to_list(Msg);
normalize_msg(Other) ->
    io_lib:format("~p", [Other]).

%%%-------------------------------------------------------------------
%%% @author mdaguete
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. mar 2014 16:13
%%%-------------------------------------------------------------------
-module(erncryptor_test_utils).
-author("mdaguete").



%% API
-export([load_test_file/3]).
-export([trimre/1]).
-export([clean_spaces/1]).


load_test_file(File,ParseFun,ParseFunAcc) ->

  {ok,Contents} = file:read_file(File),
  Lines = binary:split(Contents,<<"\n\n">>,[global]),
  Uncommented = lists:filter(
    fun(<<"#",_/binary>>) ->
      false;
      (_) ->
        true
    end, Lines),
  lists:map(
    fun(E) ->
      ParseFun(binary:split(E,<<"\n">>,[global]),ParseFunAcc)
    end,
    Uncommented
  ).









trimre(Bin) ->
  re:replace(Bin, "^\\s+|\\s+$", "", [{return, binary}, global]).

clean_spaces(Bin) ->
  re:replace(Bin, "\\s", "", [{return, binary}, global]).

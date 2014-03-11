%%%-------------------------------------------------------------------
%%% @author mdaguete
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. mar 2014 12:27
%%%-------------------------------------------------------------------
-module(kdf_tests).
-author("mdaguete").

-include_lib("eunit/include/eunit.hrl").

-record(test_kdf,{title,version,password,salt_hex,key_hex}).




kdf_test_() ->
  TestFun = fun(#test_kdf{}=E)    ->
                {ok,P} = erncryptor:kdf(E#test_kdf.password,
                  erncryptor:hexstr_to_bin(E#test_kdf.salt_hex),10000,32),
                P
    end,
  { inparallel,
    [{E#test_kdf.title,?_assertEqual(erncryptor:hexstr_to_bin(E#test_kdf.key_hex), TestFun(E))} ||
      E <- erncryptor_test_utils:load_test_file("vectors/v3/kdf",fun block_from_lines/2,#test_kdf{})]
  }.




block_from_lines([],Acc) ->
  Acc;
block_from_lines([<<>>],Acc) ->
  Acc;
block_from_lines([<<"title:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{title=erncryptor_test_utils:trimre(Rest)});
block_from_lines([<<"version:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{version=erncryptor_test_utils:trimre(Rest)});
block_from_lines([<<"password:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{password=erncryptor_test_utils:trimre(Rest)});
block_from_lines([<<"salt_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{salt_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))});
block_from_lines([<<"key_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{key_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))}).




%%%-------------------------------------------------------------------
%%% @author mdaguete
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. mar 2014 16:21
%%%-------------------------------------------------------------------
-module(password_tests).
-author("mdaguete").

-include_lib("eunit/include/eunit.hrl").

-record(test_kdf,{
  title,
  version,
  password,
  enc_salt_hex,
  hmac_salt_hex,
  iv_hex,
  plaintext_hex,
  ciphertext_hex
}).




password_test_() ->
  TestFun = fun(#test_kdf{}=E) ->
    Version = erlang:binary_to_integer(E#test_kdf.version),
    Options = 1,
    EncryptionSalt  = erncryptor:hexstr_to_bin(E#test_kdf.enc_salt_hex),
    HMACSalt  =       erncryptor:hexstr_to_bin(E#test_kdf.hmac_salt_hex),
    IV =              erncryptor:hexstr_to_bin(E#test_kdf.iv_hex),
    Header = <<Version:8, Options:8, EncryptionSalt:8/binary, HMACSalt:8/binary, IV:16/binary>>,
    {ok,EncryptionKey} = erncryptor:kdf(E#test_kdf.password,EncryptionSalt,10000,32),
    {ok,HMACKey} = erncryptor:kdf(E#test_kdf.password,HMACSalt,10000,32),
    Plaintext =  erncryptor:hexstr_to_bin(E#test_kdf.plaintext_hex),
    io:format("Vector data ~n"
    "Version:~p~nOptions:~p~nIV:~p~nEncryptionSalt~p~nHMACKey:~p~nPlaintext:~p~nExpected:~p~n",
      [Version,
        Options,
        erncryptor:bin_to_hexstr(IV),
        erncryptor:bin_to_hexstr(EncryptionSalt),
        erncryptor:bin_to_hexstr(HMACKey),
        erncryptor:bin_to_hexstr(Plaintext),
        erncryptor:bin_to_hexstr(erncryptor:hexstr_to_bin(E#test_kdf.ciphertext_hex))
      ]),

    erncryptor:encrypt(Header,IV,EncryptionKey,HMACKey,Plaintext)
  end,
  [{E#test_kdf.title, ?_assertEqual(erncryptor:hexstr_to_bin(E#test_kdf.ciphertext_hex), TestFun(E))} ||
    E <- erncryptor_test_utils:load_test_file("vectors/v3/password",fun block_from_lines/2,#test_kdf{})].



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
block_from_lines([<<"enc_salt_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{enc_salt_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))});
block_from_lines([<<"hmac_salt_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{hmac_salt_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))});
block_from_lines([<<"iv_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{iv_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))});
block_from_lines([<<"plaintext_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{plaintext_hex=erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))});
block_from_lines([<<"ciphertext_hex:",Rest/binary>> |Lines],#test_kdf{} = Acc) ->
  block_from_lines(Lines,Acc#test_kdf{ciphertext_hex =erncryptor_test_utils:clean_spaces(erncryptor_test_utils:trimre(Rest))}).

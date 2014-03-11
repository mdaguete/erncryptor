%%%-------------------------------------------------------------------
%%% @author mdaguete
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. mar 2014 19:03
%%%-------------------------------------------------------------------
-module(simple_tests).
-author("mdaguete").

-include_lib("eunit/include/eunit.hrl").

-define(PLAIN_TEXT,<<"Hello, World! Let's use a few blocks with a longer sentence.">>).
-define(PASSWORD,<<"P@ssw0rd!">>).
-define(ENC_DATA,"0301835b93e734143340ca8b55fc77865be906abe119073b77d5bc461fcc8bc8aea42fde3eb01b33bd3b54f2d58aaaef7747d24e1bde83aab5f81d7e68e3e2ba6c4f1420b638faea3d6dec7c801345d5bc059289f52b4d030786fc11e22a3939efd7c88a6cad3e23a9fc87e6bbfbc38901525b2ef7384045923260b3928a5bedbf7b").


%% API
-export([]).


simple_test_() ->
      [
        {"Decrypts v3 data with password" ,
          ?_assertEqual(?PLAIN_TEXT,
            erncryptor:decrypt(?PASSWORD,erncryptor:hexstr_to_bin(?ENC_DATA)))},
        {"Encrypt with password should decrypt",
          ?_assertEqual(?PLAIN_TEXT,
            erncryptor:decrypt(?PASSWORD,erncryptor:encrypt(?PASSWORD,?PLAIN_TEXT)))},
        {"Encrypts and decrypts larger blocks of data",large_block()},
        {"Fails to decrypt when wrong password is used",
          ?_assertEqual({ko,false},
            erncryptor:decrypt(<<"WRONG">>,erncryptor:encrypt(?PASSWORD,?PLAIN_TEXT)))
        },
        {"Should properly encrypt and decrypt multibyte passwords in v3",
          ?_assertEqual(?PLAIN_TEXT,
            erncryptor:decrypt(<<"中文密码">>,erncryptor:encrypt(<<"中文密码">>,?PLAIN_TEXT)))

        }

      ].



large_block() ->
  Data = crypto:rand_bytes(4043),
  ?_assertEqual(Data,erncryptor:decrypt(?PASSWORD,erncryptor:encrypt(?PASSWORD,Data))).
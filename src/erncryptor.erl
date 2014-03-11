%%%-------------------------------------------------------------------
%%% @author Manuel Duran Aguete
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(erncryptor).
-author("@mdaguete").

%% API
-export([decrypt/2]).
-export([encrypt/2]).
-export([encrypt/3]).
-export([encrypt/5]).
-export([kdf/4]).
-export([hexstr_to_bin/1]).
-export([bin_to_hexstr/1]).

decrypt(Password,<<3:8, 1:8, EncryptionSalt:8/binary, HMacSalt:8/binary, IV:16/binary, MessageAndMAC/binary>>) ->
  Version = 3,
  Options = 1,
  MessageAndMACSize = erlang:byte_size(MessageAndMAC),
  HMAC = erlang:binary_part(MessageAndMAC,{MessageAndMACSize,-32}), %Last 32 bytes
  CipherText = erlang:binary_part(MessageAndMAC,{0,MessageAndMACSize - 32}),
  {ok,EncryptionKey} = kdf(Password,EncryptionSalt,10000,32),
  {ok,HMACKey} =kdf(Password,HMacSalt,10000,32),
  Header = <<Version:8, Options:8, EncryptionSalt:8/binary, HMacSalt:8/binary, IV:16/binary>>,
  case pbkdf2:compare_secure(HMAC,crypto:hmac(sha256, HMACKey,<<Header/binary, CipherText/binary>>,32))  of
    true ->
      PaddedPlaintext = crypto:block_decrypt(aes_cbc256,EncryptionKey,IV,CipherText),
      Size = erlang:byte_size(PaddedPlaintext),
      PadLength = binary:at(PaddedPlaintext,Size -1),
      erlang:binary_part(PaddedPlaintext,{0,Size - PadLength});
    Error -> {ko,Error}
  end.


encrypt(Password,Plaintext) when erlang:byte_size(Password) > 0 ->
  Version = 3,
  Options = 1,
  EncryptionSalt = crypto:rand_bytes(8),
  {ok,EncryptionKey}  = kdf(Password,EncryptionSalt,10000,32),
  HMACSalt = crypto:rand_bytes(8),
  {ok, HMACKey} = kdf(Password,HMACSalt,10000,32),
  IV = crypto:rand_bytes(16),
  Header = <<Version:8, Options:8, EncryptionSalt:8/binary, HMACSalt:8/binary, IV:16/binary>>,
  encrypt(Header,IV,EncryptionKey,HMACKey,Plaintext).




encrypt(EncryptionKey,HMACKey,Plaintext) ->
  Version = 3,
  Options = 0,
  IV = crypto:rand_bytes(16),
  Header = <<Version:8, Options:8, IV:16/binary>>,
  encrypt(Header,IV,EncryptionKey,HMACKey,Plaintext).




encrypt(Header,IV,EncryptionKey,HMACKey,Plaintext) ->
  %Pad Plaintext
  Data = pad(Plaintext),
  Ciphertext = crypto:block_encrypt(aes_cbc256,EncryptionKey,IV,Data),
  HMAC = crypto:hmac(sha256,HMACKey,<<Header/binary, Ciphertext/binary>>),
  <<Header/binary, Ciphertext/binary, HMAC/binary>>.


pad(Data) ->
  Size = case 16 - (erlang:byte_size(Data) rem 16) of
              0 ->
                16;
              S ->
                S
            end,
  Padding = erlang:list_to_binary(lists:duplicate(Size,Size)),
  <<Data/binary,Padding/binary>>.




kdf(Password,Salt,Iterations,Length) ->
  pbkdf2:pbkdf2(sha,Password,Salt,Iterations,Length).



bin_to_hexstr(Bin) ->
  lists:flatten([io_lib:format("~2.16.0B", [X]) ||
    X <- binary_to_list(Bin)]).

hexstr_to_bin(S) when is_binary(S) ->
  hexstr_to_bin(binary_to_list(S), []);
hexstr_to_bin(S) ->
  hexstr_to_bin(S, []).
hexstr_to_bin([], Acc) ->
  list_to_binary(lists:reverse(Acc));
hexstr_to_bin([X,Y|T], Acc) ->
  {ok, [V], []} = io_lib:fread("~16u", [X,Y]),
  hexstr_to_bin(T, [V | Acc]);
hexstr_to_bin([X|T], Acc) ->
  {ok, [V], []} = io_lib:fread("~16u", lists:flatten([X,"0"])),
  hexstr_to_bin(T, [V | Acc]).
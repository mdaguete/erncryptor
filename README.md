# Erlang RNCryptor (erncryptor)



This is an Erlang port of Rob Napier's [RNCryptor](http://rncryptor.github.io/),implementing, at this moment, the [v3 spec](https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md).

The library passes all the vector tests for v3 version.


## Usage example:

Clone the repository. Compile the code with `make`.Test the library with `make test`.Fire up an erlang console with `make console`

    Eshell V5.10.4  (abort with ^G)
    1> Password = <<"P@ssw0rd!">>.
    <<"P@ssw0rd!">>
    2> Plaintext = <<"Hello, World! Let's use a few blocks with a longer sentence.">>.
    <<"Hello, World! Let's use a few blocks with a longer sentence.">>
    3> Encrypted = erncryptor:encrypt(Password,Plaintext).
    <<3,1,144,78,155,173,194,253,197,41,84,73,41,114,63,233,
    244,141,126,162,139,92,135,231,26,142,39,203,103,...>>
    4> erncryptor:decrypt(Password,Encrypted).
    <<"Hello, World! Let's use a few blocks with a longer sentence.">>


## Release Notes


2014-03-11 - Version 3.0

- Generates version 3 data.
- Decrypts version 3 data.


## Credits


- Original RNCrypto library and format are by Rob Napier.


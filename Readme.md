
# SHA3SML

Sha3SML (which is abbreviated for [SHA3 - StandardML]) is a SHA3 algorithm implementation with pure StandardML.
SHA3 is a cryptographic hash algorithm defined as [FIPS202].


## Supported functions

SHA3 standard declares some hash function variations.
Sha3SML implements a part of the functions.

|Hash Function|Supported |
|:------------|:--------:|
|SHA3-224     |  ✔       |
|SHA3-256     |  ✔       |
|SHA3-384     |  ✔       |
|SHA3-512     |  ✔       |
|SHAKE-128    |  ✗       |
|SHAKE-256    |  ✗       |

✔ empty input is supported
✔ byte oriented input is supported
✗ bit oriented input is unsupported


## Environments

This library has been developped with [SML/NJ] **110.98**, but recent versions should be work well.
When you generate documents of Sha3SML, [SMLDoc] is also required.


## Build

To build this library and generates docs using [SMLDoc], specify the target `libsha3sml`.

```sh
$ make libsha3sml
```

To build `libsha3sml` without docs, just run the `make` command.

```sh
$ make
```

Or specify the target `libsha3sml-nodoc`.

```sh
$ make libsha3sml-nodoc
```


## Install

To install `libsha3sml`, specify the `install` target.

```sh
$ make install [PREFIX=/path/to/install]
```

or without doc:

```sh
$ make install-nodoc [PREFIX=/path/to/install]
```


## Document

The `doc` target generates documents using [SMLDoc].

```sh
$ make doc
```


## Test

To run unit tests, run the `test` target.
This target additionally requires [SMLUnit].

```sh
$ make test
```

In addition, if you want to test this library thoroughly, run the `test-ignored` target.
This target will test the generation of 100,000 digests.
This test will take several hours to run.

```sh
$ make test-ignored
```


[SML/NJ]: https://www.smlnj.org/ "Standard ML of New Jersey"

[SMLDoc]: https://www.pllab.riec.tohoku.ac.jp/smlsharp//?SMLDoc "SMLDoc"

[SMLUnit]: https://github.com/smlsharp/SMLUnit "SMLUnit"

[FIPS202]: https://doi.org/10.6028/NIST.FIPS.202 "SHA-3 Standard: Permutation-Based Hash and Extendable-Output Functions"

[SHA3VS]: https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Algorithm-Validation-Program/documents/sha3/sha3vs.pdf "Secure Hash Algorithm-3 Validation System (SHA3VS)"

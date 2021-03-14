
# SHA3SML

Sha3SML (which is abbreviated for [SHA3 - StandardML]) is a SHA3 algorithm implementation with pure StandardML.
SHA3 is a cryptographic hash algorithm standard defined as [FIPS202].


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

- ✔ empty input is supported
- ✔ byte oriented input is supported
- ✔ bit oriented input is supported


## Environments

This library has been confirmed to work with [SML/NJ] **110.99**, but recent versions should be work well.
When you generate documents of Sha3SML, [SMLDoc] is also required.


## Build

To build this library, just run the command `make`. Or run the target `libsha3sml` explicitly.

```sh
$ make [libsha3sml]
```

The target `libsha3sml` generates documentation of Sha3SML using [SMLDoc].
If you do not need to generate documentation, run the `libsha3sml-nodoc` target.

```sh
$ make libsha3sml-nodoc
```


## Install

To install `libsha3sml`, run the `install` target.

```sh
$ make install [PREFIX=/path/to/install]
```

or without doc:

```sh
$ make install-nodoc [PREFIX=/path/to/install]
```

These targets will instruct you to add an entry to your _PATHCONFIG_ file.

```sh
$ echo 'libsha3sml.cm /path/to/install/libsha3sml.cm' >> ~/.smlnj-pathconfig
```


## How to use

### Use from other projects

After installation, Sha3SML can be referenced from other projects as `$/libsha3sml.cm` like:

```
(* sources.cm *)
group
is
  $/basis.cm
  $/libsha3sml.cm
  main.sml
```

### Load to the interactive environment

Users also can load Sha3SML into the interactive environment:

```sh
$ sml
- CM.make "$/libsha3sml.cm";
(* ... snip ... *)
val it = true : bool
- Sha3.hashString Sha3Kind.Sha3_256 "";
val it = - : Sha3.t
- Sha3.toString it;
val it = "A7FFC6F8BF1ED76651C14756A061D662F580FF4DE43B49FA82D80A4B80F8434A" :
  string
```


## Document

The `doc` target generates documentation using [SMLDoc].

```sh
$ make doc
```


## Test

Sha3SML is validated using a number of test cases consisting of examples with intermediate values provided in [Cryptographic Standards and Guidelines][EXVALS] and test vectors provided in [Cryptographic Algorithm Validation Program][CAVP].

To run unit test, run the `test` target. This target depends on [SMLUnit].

```sh
$ make test
```

Additionally, if you want to test this library thoroughly, run the `test-ignored` target.
This target will test the generation of over 100,000 digests in addition to a large number of test cases.
This test will take several hours to run.

```sh
$ make test-ignored
```


[SML/NJ]: https://www.smlnj.org/ "Standard ML of New Jersey"

[SMLDoc]: https://www.pllab.riec.tohoku.ac.jp/smlsharp//?SMLDoc "SMLDoc"

[SMLUnit]: https://github.com/smlsharp/SMLUnit "SMLUnit"

[FIPS202]: https://doi.org/10.6028/NIST.FIPS.202 "SHA-3 Standard: Permutation-Based Hash and Extendable-Output Functions"

[EXVALS]: https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values "Cryptographic Standards and Guidelines"

[CAVP]: https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/secure-hashing "Cryptographic Algorithm Validation Program"

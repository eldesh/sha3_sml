
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

This library has been developped using the following versions of [SML/NJ][SML/NJ] and [MLton][MLTON].
However, recent versions should be work well.

- [SML/NJ] 110.99
- [MLton] 20210117

[SMLDoc][SMLDoc] is also required to generate documentation of Sha3SML.


## Build

### SML/NJ

To build this library and generates docs, specify the target `libsha3sml`.

```sh
$ make [libsha3sml]
```

The target `libsha3sml` generates documentation of Sha3SML using [SMLDoc].
If you do not need to generate documentation, run the `libsha3sml-nodoc` target.

```sh
$ make -f Makefile.smlnj libsha3sml-nodoc
```

### MLton

MLton is a whole optimizing compiler, so any `build` target is not provided.
But the target `libsha3sml` and `libsha3sml-nodoc` are provided for type checking and generating documentation (option).


Type checking:

```sh
$ make -f Makefile.mlton libsha3sml
```

Type checking without docs:

```sh
$ make -f Makefile.mlton libsha3sml-nodoc
```


## Install

### SML/NJ

To install `libsha3sml`, run the `install` target.

```sh
$ make -f Makefile.smlnj install [PREFIX=/path/to/install]
```

or without doc:

```sh
$ make -f Makefile.smlnj install-nodoc [PREFIX=/path/to/install]
```

These targets will instruct you to add an entry to your _PATHCONFIG_ file.

```sh
$ echo 'libsha3sml.cm /path/to/install/libsha3sml.cm' >> ~/.smlnj-pathconfig
```

### MLton

To install `libsha3sml`, specify the `install` target.

```sh
$ make -f Makefile.mlton install [PREFIX=/path/to/install]
```

or without doc:

```sh
$ make -f Makefile.mlton install-nodoc [PREFIX=/path/to/install]
```

These targets will instruct you to add an entry to your `mlb-path-map` file.

```sh
$ echo 'SHA3SML /path/to/install/libsha3sml' >> /path/to/lib/mlb-path-map
```


## How to use

### SML/NJ: Use from other projects

After installation, Sha3SML can be referenced from other projects as `$/libsha3sml.cm` like:

```
(* sources.cm *)
group
is
  $/basis.cm
  $/libsha3sml.cm
  main.sml
```

### SML/NJ: Load to the interactive environment

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


### MLton

After installation, Sha3SML can be referenced from other projects as `$(SHA3SML)/libsha3sml.mlb` like:

```
(* sources.mlb *)
$(SML_LIB)/basis/basis.cm
$(SHA3SML)/libsha3sml.mlb
main.sml
```

```sh
$ mlton -mlb-path-map /path/to/lib/mlb-path-map sources.sml && ./sources
```


## Document

### SML/NJ

The `doc` target generates documentation using [SMLDoc].

```sh
$ make -f Makefile.smlnj doc
```

### MLton

The `doc` target generates documentation using [SMLDoc].

```sh
$ make -f Makefile.mlton doc
```


## Test

Sha3SML is validated using a number of test cases consisting of examples with intermediate values provided in [Cryptographic Standards and Guidelines][EXVALS] and test vectors provided in [Cryptographic Algorithm Validation Program][CAVP].

To run unit tests, run the `test` target.
This target requires [SMLUnit].

- SML/NJ

    ```sh
    $ make -f Makefile.smlnj test
    ```

- MLton

    ```sh
    $ make -f Makefile.mlton test
    ```

### More Test

Additionally, if you want to test this library thoroughly, run the `test-ignored` target.
This target will test the generation of over 100,000 digests large number of test cases along with [CAVP].
This test will take several hours to run.

- SML/NJ

    ```sh
    $ make -f Makefile.smlnj test-ignored
    ```

- MLton

    ```sh
    $ make -f Makefile.mlton test-ignored
    ```


[SML/NJ]: https://www.smlnj.org/ "Standard ML of New Jersey"

[MLTON]: https://github.com/mlton/mlton/ "MLton"

[SMLDoc]: https://www.pllab.riec.tohoku.ac.jp/smlsharp//?SMLDoc "SMLDoc"

[SMLUnit]: https://github.com/smlsharp/SMLUnit "SMLUnit"

[FIPS202]: https://doi.org/10.6028/NIST.FIPS.202 "SHA-3 Standard: Permutation-Based Hash and Extendable-Output Functions"

[EXVALS]: https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values "Cryptographic Standards and Guidelines"

[CAVP]: https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/secure-hashing "Cryptographic Algorithm Validation Program"

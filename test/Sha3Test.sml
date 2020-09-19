
structure Sha3Test =
struct
  open SMLUnit
  open Assert
  val ($,%,&,?) = let open Test in (TestLabel, TestCase, TestList, assert) end

  open Sha3Kind

  local
    val ` = Sha3.fromHexString
    val hash = Sha3.hashString
    val assert_eq = assertEqual op= Sha3.toString
  in
    (*
     * https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values
     *)
    fun examples () =
      $("examples",
        &[ $("SHA3-224_Msg0",
              %(fn()=> assert_eq (`"6B4E03423667DBB73B6E15454F0EB1ABD4597F9A1B078E3F5B5A6BC7")
                                 (hash Sha3_224 ""))),
           $("SHA3-256_Msg0",
              %(fn()=> assert_eq (`"A7FFC6F8BF1ED76651C14756A061D662F580FF4DE43B49FA82D80A4B80F8434A")
                                 (hash Sha3_256 ""))),
           $("SHA3-384_Msg0",
              %(fn()=> assert_eq (`"0C63A75B845E4F7D01107D852E4C2485C51A50AAAA94FC61995E71BBEE983A2AC3713831264ADB47FB6BD1E058D5F004")
                                 (hash Sha3_384 ""))),
           $("SHA3-512_Msg0",
              %(fn()=> assert_eq (`"A69F73CCA23A9AC5C8B567DC185A756E97C982164FE25859E0D1DCC1475C80A615B2123AF1F5F94C11E3E9402C3AC558F500199D95B6D3E301758586281DCD26")
                                 (hash Sha3_512 "")))
        ])
  end

  fun test () =
    $("test",
      &[ examples () ])

  fun main (_, _) =
    (TextUITestRunner.runTest {output=TextIO.stdOut} (test());
     TextIO.flushOut TextIO.stdOut;
     OS.Process.success
     )
end


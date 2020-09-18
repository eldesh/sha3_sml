
structure Sha3Test =
struct
  open SMLUnit
  open Assert
  val ($,%,&,?) = let open Test in (TestLabel, TestCase, TestList, assert) end

  open Sha3Kind

  local
    val ` = Sha3.fromHexString
    val hash = Sha3.hashString Sha3_224
    val assert_eq = assertEqual op= Sha3.toString
  in
    fun test_sha3_224 () =
      $("test_sha3_224",
        &[ %(fn()=> assert_eq (`"6B4E03423667DBB73B6E15454F0EB1ABD4597F9A1B078E3F5B5A6BC7")
                              (hash ""))
        ])
  end

  fun test () =
    $("test",
      &[ test_sha3_224 () ])

  fun main (_, _) =
    (TextUITestRunner.runTest {output=TextIO.stdOut} (test());
     TextIO.flushOut TextIO.stdOut;
     OS.Process.success
     )
end


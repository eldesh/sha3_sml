
structure Sha3Test =
struct
  open SMLUnit
  open Assert
  val ($,%,&,?) = let open Test in (TestLabel, TestCase, TestList, assert) end

  open Sha3Kind

  val ` = Sha3.fromHexString

  val assertEqualSha3 = assertEqual op= Sha3.toString
  val assert_eq = assertEqualSha3

  local
    fun hash (ws, odd) = Sha3.hashVector Sha3_224 (vector ws, odd)
    fun unfoldr f e =
      case f e
        of SOME (x, e') => x :: unfoldr f e'
         | NONE => []
    fun rep n xs =
      List.concat (unfoldr (fn 0 => NONE | n => SOME (xs, n-1)) n)
  in
    fun test_sha3_224 () =
      $("sha3_224",
        &[ $("SHA3-224_Msg0",
              %(fn()=> assert_eq (`"6B4E03423667DBB73B6E15454F0EB1ABD4597F9A1B078E3F5B5A6BC7")
                                 (hash ([], 0)))),
           $("SHA3-224_Msg5",
              %(fn()=> assert_eq (`"FFBAD5DA96BAD71789330206DC6768ECAEB1B32DCA6B3301489674AB")
                                 (hash ([0wx13], 5)))),
           $("SHA3-224_Msg30",
              %(fn()=> assert_eq (`"D666A514CC9DBA25AC1BA69ED3930460DEAAC9851B5F0BAAB007DF3B")
                                 (hash ([0wx53, 0wx58, 0wx7B, 0wx19], 6)))),
           $("SHA3-224_1600",
              %(fn()=> assert_eq (`"9376816ABA503F72F96CE7EB65AC095DEEE3BE4BF9BBC2A1CB7E11E0")
                                 (hash (rep 200 [0wxA3], 0)))),
           $("SHA3-224_1605",
              %(fn()=> assert_eq (`"22D2F7BB0B173FD8C19686F9173166E3EE62738047D7EADD69EFB228")
                                 (hash (rep 200 [0wxA3] @ [0wx03], 5)))),
           $("SHA3-224_1630",
              %(fn()=> assert_eq (`"4E907BB1057861F200A599E9D4F85B02D88453BF5B8ACE9AC589134C")
                                 (hash (rep 203 [0wxA3] @ [0wx23], 6))))
        ])
  end

  local
    fun hash (ws, odd) = Sha3.hashVector Sha3_256 (vector ws, odd)
  in
    fun test_sha3_256 () =
      $("sha3_256",
        &[ $("SHA3-256_Msg0",
              %(fn()=> assert_eq (`"A7FFC6F8BF1ED76651C14756A061D662F580FF4DE43B49FA82D80A4B80F8434A")
                                 (hash ([], 0))))
        ])
  end

  local
    fun hash (ws, odd) = Sha3.hashVector Sha3_384 (vector ws, odd)
  in
    fun test_sha3_384 () =
      $("sha3_384",
        &[ $("SHA3-384_Msg0",
              %(fn()=> assert_eq (`"0C63A75B845E4F7D01107D852E4C2485C51A50AAAA94FC61995E71BBEE983A2AC3713831264ADB47FB6BD1E058D5F004")
                                 (hash ([], 0))))
        ])
  end

  local
    fun hash (ws, odd) = Sha3.hashVector Sha3_512 (vector ws, odd)
  in
    fun test_sha3_512 () =
      $("sha3_512",
        &[ $("SHA3-512_Msg0",
              %(fn()=> assert_eq (`"A69F73CCA23A9AC5C8B567DC185A756E97C982164FE25859E0D1DCC1475C80A615B2123AF1F5F94C11E3E9402C3AC558F500199D95B6D3E301758586281DCD26")
                                 (hash ([], 0))))
        ])
  end


  (**
   * Test cases based on officially provided example values
   *
   * @see https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values
   *)
  fun test_example_values () =
    $("example_values",
      &[ test_sha3_224 ()
       , test_sha3_256 ()
       , test_sha3_384 ()
       , test_sha3_512 ()
       ])

  fun test () =
    $("test",
      &[ test_example_values () ])

  fun main (_, _) =
    (TextUITestRunner.runTest {output=TextIO.stdOut} (test());
     TextIO.flushOut TextIO.stdOut;
     OS.Process.success
     )
end


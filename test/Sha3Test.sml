
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
    fun hash224 (ws, odd) = Sha3.hashVector Sha3_224 (vector ws, odd)
    fun hash256 (ws, odd) = Sha3.hashVector Sha3_256 (vector ws, odd)
    fun hash384 (ws, odd) = Sha3.hashVector Sha3_384 (vector ws, odd)
    fun hash512 (ws, odd) = Sha3.hashVector Sha3_512 (vector ws, odd)
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
                                 (hash224 ([], 0)))),
           $("SHA3-224_Msg5",
              %(fn()=> assert_eq (`"FFBAD5DA96BAD71789330206DC6768ECAEB1B32DCA6B3301489674AB")
                                 (hash224 ([0wx13], 5)))),
           $("SHA3-224_Msg30",
              %(fn()=> assert_eq (`"D666A514CC9DBA25AC1BA69ED3930460DEAAC9851B5F0BAAB007DF3B")
                                 (hash224 ([0wx53, 0wx58, 0wx7B, 0wx19], 6)))),
           $("SHA3-224_1600",
              %(fn()=> assert_eq (`"9376816ABA503F72F96CE7EB65AC095DEEE3BE4BF9BBC2A1CB7E11E0")
                                 (hash224 (rep 200 [0wxA3], 0)))),
           $("SHA3-224_1605",
              %(fn()=> assert_eq (`"22D2F7BB0B173FD8C19686F9173166E3EE62738047D7EADD69EFB228")
                                 (hash224 (rep 200 [0wxA3] @ [0wx03], 5)))),
           $("SHA3-224_1630",
              %(fn()=> assert_eq (`"4E907BB1057861F200A599E9D4F85B02D88453BF5B8ACE9AC589134C")
                                 (hash224 (rep 203 [0wxA3] @ [0wx23], 6))))
        ])

    fun test_sha3_256 () =
      $("sha3_256",
        &[ $("SHA3-256_Msg0",
              %(fn()=> assert_eq (`"A7FFC6F8BF1ED76651C14756A061D662F580FF4DE43B49FA82D80A4B80F8434A")
                                 (hash256 ([], 0)))),
           $("SHA3-256_Msg5",
              %(fn()=> assert_eq (`"7B0047CF5A456882363CBF0FB05322CF65F4B7059A46365E830132E3B5D957AF")
                                 (hash256 ([0wx13], 5)))),
           $("SHA3-256_Msg30",
              %(fn()=> assert_eq (`"C8242FEF409E5AE9D1F1C857AE4DC624B92B19809F62AA8C07411C54A078B1D0")
                                 (hash256 ([0wx53, 0wx58, 0wx7B, 0wx19], 6)))),
           $("SHA3-256_Msg1600",
              %(fn()=> assert_eq (`"79F38ADEC5C20307A98EF76E8324AFBFD46CFD81B22E3973C65FA1BD9DE31787")
                                 (hash256 (rep 200 [0wxA3], 0)))),
           $("SHA3-256_Msg1605",
              %(fn()=> assert_eq (`"81EE769BED0950862B1DDDED2E84AAA6AB7BFDD3CEAA471BE31163D40336363C")
                                 (hash256 (rep 200 [0wxA3] @ [0wx03], 5)))),
           $("SHA3-256_Msg1630",
              %(fn()=> assert_eq (`"52860AA301214C610D922A6B6CAB981CCD06012E54EF689D744021E738B9ED20")
                                 (hash256 (rep 203 [0wxA3] @ [0wx23], 6))))
        ])

    fun test_sha3_384 () =
      $("sha3_384",
        &[ $("SHA3-384_Msg0",
              %(fn()=> assert_eq (`"0C63A75B845E4F7D01107D852E4C2485C51A50AAAA94FC61995E71BBEE983A2AC3713831264ADB47FB6BD1E058D5F004")
                                 (hash384 ([], 0)))),
           $("SHA3-384_Msg5",
              %(fn()=> assert_eq (`"737C9B491885E9BF7428E792741A7BF8DCA9653471C3E148473F2C236B6A0A6455EB1DCE9F779B4B6B237FEF171B1C64")
                                 (hash384 ([0wx13], 5)))),
           $("SHA3-384_Msg30",
              %(fn()=> assert_eq (`"955B4DD1BE03261BD76F807A7EFD432435C417362811B8A50C564E7EE9585E1AC7626DDE2FDC030F876196EA267F08C3")
                                 (hash384 ([0wx53, 0wx58, 0wx7B, 0wx19], 6)))),
           $("SHA3-384_Msg1600",
              %(fn()=> assert_eq (`"1881DE2CA7E41EF95DC4732B8F5F002B189CC1E42B74168ED1732649CE1DBCDD76197A31FD55EE989F2D7050DD473E8F")
                                 (hash384 (rep 200 [0wxA3], 0)))),
           $("SHA3-384_Msg1605",
              %(fn()=> assert_eq (`"A31FDBD8D576551C21FB1191B54BDA65B6C5FE97F0F4A69103424B43F7FDB835979FDBEAE8B3FE16CB82E587381EB624")
                                 (hash384 (rep 200 [0wxA3] @ [0wx03], 5)))),
           $("SHA3-384_Msg1630",
              %(fn()=> assert_eq (`"3485D3B280BD384CF4A777844E94678173055D1CBC40C7C2C3833D9EF12345172D6FCD31923BB8795AC81847D3D8855C")
                                 (hash384 (rep 203 [0wxA3] @ [0wx23], 6))))
        ])

    fun test_sha3_512 () =
      $("sha3_512",
        &[ $("SHA3-512_Msg0",
              %(fn()=> assert_eq (`"A69F73CCA23A9AC5C8B567DC185A756E97C982164FE25859E0D1DCC1475C80A615B2123AF1F5F94C11E3E9402C3AC558F500199D95B6D3E301758586281DCD26")
                                 (hash512 ([], 0)))),
           $("SHA3-512_Msg5",
              %(fn()=> assert_eq (`"A13E01494114C09800622A70288C432121CE70039D753CADD2E006E4D961CB27544C1481E5814BDCEB53BE6733D5E099795E5E81918ADDB058E22A9F24883F37")
                                 (hash512 ([0wx13], 5)))),
           $("SHA3-512_Msg30",
              %(fn()=> assert_eq (`"9834C05A11E1C5D3DA9C740E1C106D9E590A0E530B6F6AAA7830525D075CA5DB1BD8A6AA981A28613AC334934A01823CD45F45E49B6D7E6917F2F16778067BAB")
                                 (hash512 ([0wx53, 0wx58, 0wx7B, 0wx19], 6)))),
           $("SHA3-512_Msg1600",
              %(fn()=> assert_eq (`"E76DFAD22084A8B1467FCF2FFA58361BEC7628EDF5F3FDC0E4805DC48CAEECA81B7C13C30ADF52A3659584739A2DF46BE589C51CA1A4A8416DF6545A1CE8BA00")
                                 (hash512 (rep 200 [0wxA3], 0)))),
           $("SHA3-512_Msg1605",
              %(fn()=> assert_eq (`"FC4A167CCB31A937D698FDE82B04348C9539B28F0C9D3B4505709C03812350E4990E9622974F6E575C47861C0D2E638CCFC2023C365BB60A93F528550698786B")
                                 (hash512 (rep 200 [0wxA3] @ [0wx03], 5)))),
           $("SHA3-512_Msg1630",
              %(fn()=> assert_eq (`"CF9A30AC1F1F6AC0916F9FEF1919C595DEBE2EE80C85421210FDF05F1C6AF73AA9CAC881D0F91DB6D034A2BBADC1CF7FBCB2ECFA9D191D3A5016FB3FAD8709C9")
                                 (hash512 (rep 203 [0wxA3] @ [0wx23], 6))))
        ])
  end (* local *)

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

  local
    fun hash kind = Sha3.hashVector kind
    fun read_test_case path =
      let val (kind, cases) = Sha3VS.parse path in
        $(OS.Path.file path,
            &(map (fn {msg, digest} =>
                     %(fn()=> assert_eq (`digest) (hash kind msg)))
                cases))
      end
  in
  fun short_messages_test () =
    $("ShortMessagesTest",
      &(map read_test_case
          [ "test/sha3_bytetestvectors/SHA3_224ShortMsg.rsp"
          , "test/sha3_bytetestvectors/SHA3_256ShortMsg.rsp"
          , "test/sha3_bytetestvectors/SHA3_384ShortMsg.rsp"
          , "test/sha3_bytetestvectors/SHA3_512ShortMsg.rsp"
          ]))

  fun long_messages_test () =
    $("LongMessagesTest", &[])

  fun pseudorandomly_generated_messages_test () =
    $("PseudorandomlyGeneratedMessagesTest", &[])
  end (* local *)

  (**
   * Tests for SHA3 Validation System Test Vectors
   * Test cases use test vectors of CAVP (Cryptographic Algorithm Validation Progoram).
   *
   * @see https://csrc.nist.gov/Projects/Cryptographic-Algorithm-Validation-Program/Secure-Hashing#sha3vsha3vss
   *)
  fun test_sha3vs () =
    $("test_sha3vs",
      &[ short_messages_test (),
         long_messages_test (),
         pseudorandomly_generated_messages_test ()
       ])

  fun test () =
    $("test",
      &[ test_example_values (),
         test_sha3vs ()
       ])

  fun main (_, _) =
    (TextUITestRunner.runTest {output=TextIO.stdOut} (test());
     TextIO.flushOut TextIO.stdOut;
     OS.Process.success
     )
end


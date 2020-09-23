
structure Sha3 :> SHA3 =
struct
  datatype t = T of Word8.word vector
  datatype z = datatype Sha3Kind.t

  fun toVector (T vec) = vec

  exception InvalidFormat of string

  local
    structure SS = Substring
  in
  fun unfold f e =
    case f e
      of SOME (x, e') => x :: unfold f e'
       | NONE         => []

  fun fromHexString str =
    let
      fun get ss =
        let
          val w = if SS.isEmpty ss then
                    NONE
                  else
                    SOME(SS.splitAt (ss, 2))
                    handle Subscript =>
                      raise InvalidFormat ("for Word8.word: " ^ SS.string ss)
        in
          Option.map
            (fn(w,ws) => (valOf (Word8.fromString (SS.string w)), ws))
            w
          handle Option =>
            raise InvalidFormat ("for Word8.word: " ^ SS.string ss)
        end
    in
      T (vector (unfold get (SS.full str)))
    end
  end

  fun toString (T vec) =
    let
      val strs =
        Vector.foldl
          (fn (w,xs) =>
             StringCvt.padLeft #"0" 2
               (Word8.fmt StringCvt.HEX w) :: xs)
          []
          vec
    in
      concat (rev strs)
    end

  fun hashBitArray kind =
    case kind
      of Sha3_224 => Keccak.sha3_224
       | Sha3_256 => Keccak.sha3_256
       | Sha3_384 => Keccak.sha3_384
       | Sha3_512 => Keccak.sha3_512

  fun hashString kind m =
    let
      val M = BitArray.fromWordVector
                (vector
                  (map (Word8.fromInt o ord) (explode m)), 0)
    in
      T (BitArray.vector (hashBitArray kind M))
    end

  fun hashVector kind (m, oddm) =
    let
      val M = BitArray.fromWordVector (m, oddm)
    in
      T (BitArray.vector (hashBitArray kind M))
    end

  fun hashVectorSlice kind (m, oddm) =
    let
      val M = BitArray.fromWordVector (VectorSlice.vector m, oddm)
    in
      T (BitArray.vector (hashBitArray kind M))
    end

end


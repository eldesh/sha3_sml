
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
  (**
   * Read a value of type t from HEX string
   *)
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

  (**
   * Convert to string
   *)
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

  (**
   * Hash a string
   *
   * @params kind m
   * @param kind kind of hash
   * @param m input message string
   *)
  fun hashString kind m =
    let
      val M = BitArray.fromWordVector
                (vector
                  (map (Word8.fromInt o ord) (explode m)))
      val M' =
        case kind
          of Sha3_224 => Keccak.sha3_224 M
           | Sha3_256 => Keccak.sha3_256 M
           | Sha3_384 => Keccak.sha3_384 M
           | Sha3_512 => Keccak.sha3_512 M
    in
      T (BitArray.vector M')
    end
end



structure Sha3Kind =
struct
  (**
   * The kind of SHA3 algorithms
   * Suffixes represent the bit length of message digest(= output) size.
   *)
  datatype t = Sha3_224
             | Sha3_256
             | Sha3_384
             | Sha3_512

  (**
   * Hash algorithms string representation.
   *)
  fun toString t =
    case t
      of Sha3_224 => "SHA3-224"
       | Sha3_256 => "SHA3-256"
       | Sha3_384 => "SHA3-384"
       | Sha3_512 => "SHA3-512"
end


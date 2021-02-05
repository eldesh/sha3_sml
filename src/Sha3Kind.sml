
structure Sha3Kind =
struct
  (**
   * The kind of SHA3 algorithms
   * Suffix of hash type(Sha3_...) represents the bit length of message digest(= output) size.
   *)
  datatype t = Sha3_224
             | Sha3_256
             | Sha3_384
             | Sha3_512
             | (** SHAKE128 with output length [d] *)
               Shake128 of Int.int
             | (** SHAKE256 with output length [d] *)
               Shake256 of Int.int

  (**
   * Hash algorithms string representation.
   *)
  fun toString t =
    case t
      of Sha3_224 => "SHA3-224"
       | Sha3_256 => "SHA3-256"
       | Sha3_384 => "SHA3-384"
       | Sha3_512 => "SHA3-512"
       | Shake128 d => "SHAKE128(" ^ Int.toString d ^ ")"
       | Shake256 d => "SHAKE256(" ^ Int.toString d ^ ")"
end


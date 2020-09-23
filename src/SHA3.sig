
signature SHA3 =
sig
  eqtype t

  (**
   * Convert to byte vector
   *)
  val toVector : t -> Word8.word vector

  (**
   * Read a value of type t from HEX string
   *)
  val fromHexString : string -> t

  (**
   * Convert to string
   *)
  val toString : t -> string

  (**
   * Hash a string
   *
   * @params kind m
   * @param kind kind of hash
   * @param m input message string
   * @return hashed string
   *)
  val hashString : Sha3Kind.t -> string -> t

  (**
   * Hash a word vector
   *
   * @params kind (m, oddm)
   * @param kind kind of hash
   * @param m    input message string
   * @param oddm number of odd bits last string of m. oddm must be in the range [0, 8).
   *        (M, 0) means that the input message length is <i>8*n</i> bits.
   *        (M, 2) means that the input message length is <i>8*n + 2</i> bits.
   * @return hashed string specified by kind
   * @exception General.Domain raise if oddm exceeds the size of Word8.word.
   *)
  val hashVector : Sha3Kind.t -> Word8.word vector * int -> t

  (**
   * Hash a word vector slice
   *
   * @params kind (m, oddm)
   * @param kind kind of hash
   * @param m    input message string
   * @param oddm number of odd bits last string of m. oddm must be in the range [0, 8).
   *        (M, 0) means that the input message length is <i>8*n</i> bits.
   *        (M, 2) means that the input message length is <i>8*n + 2</i> bits.
   * @return hashed string specified by kind
   * @exception General.Domain raise if oddm exceeds the size of Word8.word.
   *)
  val hashVectorSlice : Sha3Kind.t -> Word8.word VectorSlice.slice * int -> t
end


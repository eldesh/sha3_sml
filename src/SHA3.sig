
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
   *)
  val hashString : Sha3Kind.t -> string -> t
end



signature BIT_VECTOR =
sig
  type t

  val fromWordVector : Word8.word vector * int -> t

  val vector : t -> Word8.word vector

  val length : t -> int

  val sub : t * int -> Bit.t

  val dump : TextIO.outstream * t -> unit
end


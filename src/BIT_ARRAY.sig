
signature BIT_ARRAY =
sig
  type t

  val array : int -> t

  val fromVector : Bit.t vector -> t

  val fromWordVector : Word8.word vector * int -> t

  val vector : t -> Word8.word vector

  val length : t -> int

  val sub : t * int -> Bit.t

  val update : t * int * Bit.t -> unit

  val clone : t -> t

  val copy : { src: t, dst: t } -> unit

  val range : t * int * int -> t

  val || : t * t -> t

  val |+| : t * t -> t

  val dump : TextIO.outstream * t -> unit
end


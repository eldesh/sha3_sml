
(**
 * The state for the <i>KECCAK-p[b, nr]</i> permutation.
 *
 * This is a string of <i>b</i> bits.
 * Usually, this is denoted by <b>S</b>.
 *)
structure State :> sig
  type t

  val fromArray : BitArray.t -> t

  val toArray : t -> BitArray.t

  val length : t -> int

  val sub : t * int -> Bit.t

  val update : t * int * Bit.t -> unit

  val clone : t -> t

  val w : t -> int

  val l : t -> int

  val dump : TextIO.outstream * t -> unit
end =
struct
  structure Arr = BitArray

  datatype t = State of Arr.t

  fun fromArray arr = State arr

  fun toArray (State arr) = arr

  fun length (State arr) = Arr.length arr

  fun sub (State a, n) =
    Arr.sub (a, n)

  fun update (State a, n, b) =
    Arr.update (a, n, b)

  fun clone (State arr) =
    State (Arr.clone arr)

  (**
   * b/25
   *)
  fun w (State ba) = Arr.length ba div 25

  fun log2 x = (Math.log10 x) / (Math.log10 2.0)

  (**
   * log 2 (b/25)
   *)
  fun l (State ba) =
    Real.toInt IEEEReal.TO_NEAREST (log2 (real (Arr.length ba div 25)))

  fun dump (out, State arr) = Arr.dump (out, arr)
end



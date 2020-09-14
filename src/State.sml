
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

  (**
   * b/25
   *)
  val w : t -> int

  (**
   * log 2 (b/25)
   *)
  val l : t -> int
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

  fun w (State ba) = Arr.length ba div 25

  fun log2 x = (Math.log10 x) / (Math.log10 2.0)

  fun l (State ba) =
    Real.toInt IEEEReal.TO_NEAREST (log2 (real (Arr.length ba div 25)))
end



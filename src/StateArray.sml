
(**
 * State Arrays denoted by <b>A</b>
 *
 * For all triples (x,y,z) such that 0<=x<5, 0<=y<5, and 0<=z<w,
 *   A[x,y,z] = S[w(5y + x)+z]
 *)
structure StateArray : sig
  type t

  (**
   * 5-by-5-by-w
   *)
  val size : t -> int

  val fromState : State.t -> t

  val toState   : t -> State.t

  val sub : t * int * int * int -> Bit.t

  val update : t * int * int * int * Bit.t -> unit

  val clone : t -> t

  val dump : TextIO.outstream * t -> unit
end =
struct
  datatype t = A of State.t

  fun size (A state) = 5 * 5 * State.w state

  fun fromState state = A state

  fun toState (A state) = state

  fun sub (A state, x, y, z) =
    State.sub (state, State.w state * (5 * y + x) + z)

  fun update (A state, x, y, z, b) =
    State.update (state, State.w state * (5 * y + x) + z, b)

  fun clone (A state) =
    A (State.clone state)

  fun dump (out, A state) = State.dump (out, state)
end


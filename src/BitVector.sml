
structure BitVector :> BIT_VECTOR =
struct
  structure W = Word8
  open ForLoop

  datatype t = T of
    {
      bytes: W.word Vector.vector,
      bits: int
    }

  exception InvariantError of string

  fun invariant_err ss = raise InvariantError (concat ss)

  infix 6 //
  fun a // n = Vector.sub (a, n)

  local
    val int = Int.toString
    val word = W.toString
  in
  fun fromWordVector (bytes:W.word Vector.vector, bits:int) =
    if bits < 0 orelse W.wordSize <= bits then (* invalid range *)
      invariant_err ["bits must be in the range of [0,8): ", int bits]
    else if Vector.length bytes = 0 andalso bits <> 0 then (* invalid odd bits *)
      invariant_err ["length bytes = 0 -> bits = 0: ", int bits]
    else if Vector.length bytes = 0 then (* empty *)
      T { bytes = bytes, bits = bits }
    else (* 0 < Vector.length bytes *)
      let
        val last = bytes // (Vector.length bytes - 1)
        val mask = W.<< (0w1, Word.fromInt ((W.wordSize - bits) mod W.wordSize)) - 0w1
      in
        if W.andb (last, W.<< (mask, Word.fromInt bits)) <> 0w0 then
          invariant_err ["remainder bits of the last word should be 0: ", word last]
        else
          T { bytes = bytes, bits = bits }
      end
  end (* local *)

  fun vector (T { bytes, ... }) = bytes

  fun length (T { bytes, bits }) =
    let val len = Vector.length bytes in
      len * W.wordSize - (W.wordSize - bits) mod W.wordSize
    end

  fun sub (vec as T { bytes, ... }, n) : Bit.t =
    let
      val bits = length vec
    in
      if n < 0 orelse bits <= n then
        raise Subscript
      else
        let
          val (n, n') = (n div W.wordSize, n mod W.wordSize)
          val elem = W.andb (bytes // n, W.<< (0w1, Word.fromInt n'))
        in
          if elem <> 0w0 then Bit.I else Bit.O
        end
    end

  local
    structure IO = TextIO
    structure Cvt = StringCvt
  in
  fun dump (out, T { bytes, bits }) =
    let
      fun out' ss = IO.output (out, ss)
    in
      for 0 (fn i => i < Vector.length bytes) inc (fn i =>
        ( out' (Cvt.padLeft #"0" 2 (W.fmt Cvt.HEX (bytes // i)));
          out' (if i mod 16 = 15 then "\n" else " ")
        )
      );
      out' "\n";
      IO.flushOut out
    end
  end (* local *)
end



structure BitArray :> sig
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
end =
struct
  structure W = Word8
  open ForLoop

  datatype t = T of
    {
      bytes: W.word Array.array,
      bits: int
    }

  exception InvariantError of string

  fun invariant_err ss = raise InvariantError (concat ss)

  local
    val int = Int.toString
    val word = W.toString
  in
  fun fromWordArray { bytes: W.word Array.array, bits: int } =
    if bits < 0 orelse W.wordSize <= bits then (* invalid range *)
      invariant_err ["bits must be in the range of [0,8): ", int bits]
    else if Array.length bytes = 0 andalso bits <> 0 then (* invalid odd bits *)
      invariant_err ["length bytes = 0 -> bits = 0: ", int bits]
    else if Array.length bytes = 0 then (* empty *)
      T { bytes = bytes, bits = bits }
    else (* 0 < Array.length bytes *)
      let
        val last = Array.sub (bytes, Array.length bytes - 1)
        val mask = W.<< (0w1, Word.fromInt ((W.wordSize - bits) mod W.wordSize)) - 0w1
      in
        if W.andb (last, W.<< (mask, Word.fromInt bits)) <> 0w0 then
          invariant_err ["remainder bits of the last word should be 0: ", word last]
        else
          T { bytes = bytes, bits = bits }
      end
  end (* local *)

  fun fromWordVector (vec, oddm) =
    let
      val bytes = Array.array (Vector.length vec, 0w0)
    in
      Array.copyVec { di = 0, src = vec, dst = bytes };
      fromWordArray { bytes = bytes, bits = oddm }
    end

  fun vector (T { bytes, ... }) = Array.vector bytes

  fun array n =
    let
      val w = W.wordSize
      val bits = n mod w
      val bytes = Array.array (n div w + (if bits <> 0 then 1 else 0), 0w0)
    in
      T { bytes = bytes, bits = bits }
    end

  fun length (T { bytes, bits }) =
    let val len = Array.length bytes in
      len * W.wordSize - (W.wordSize - bits) mod W.wordSize
    end

  infix 5 :=
  fun a := (n, e) = Array.update (a, n, e)

  infix 6 //
  fun a // n = Array.sub (a, n)

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

  fun update (vec as T { bytes, ... }, n, e) =
    let
      val bits = length vec
    in
      if n < 0 orelse bits <= n then
        raise Subscript
      else
        let
          val (n, n') = (n div W.wordSize, n mod W.wordSize)
          val elem = bytes // n
        in
          case e
            of Bit.I =>
                bytes := (n, W.orb  (elem, W.<< (0w1, Word.fromInt n')))
             | Bit.O =>
                bytes := (n, W.andb (elem, W.notb (W.<< (0w1, Word.fromInt n'))))
        end
    end

  fun fromVector vec =
    let
      open ForLoop
      val arr = array (Vector.length vec)
    in
      for 0 (fn i => i < length arr) inc (fn i =>
        update (arr, i, Vector.sub (vec, i))
      );
      arr
    end

  fun clone (T { bytes, bits }) =
    let
      val bytes' = Array.array (Array.length bytes, 0w0)
    in
      Array.copy { di = 0, src = bytes, dst = bytes' };
      T { bytes = bytes', bits = bits }
    end

  fun copy { src = src as T { bytes = bytesS, bits = bitsS }
           , dst = dst as T { bytes = bytesD, bits = bitsD } } =
    if length src <> length dst then
      raise Size
    else
      Array.copy { di = 0, src = bytesS, dst = bytesD }

  fun range (arr as T { bytes = bytesA, bits = bitsA }, from, size) : t =
    let
      val len = length arr
      val () = if from < 0 orelse size < 0 then raise Subscript else ()
      val () = if len < from + size then raise Subscript else ()
      val arr' = array size
    in
      for 0 (fn i => i < size) inc (fn i =>
        update (arr', i, sub (arr, from + i))
      );
      arr'
    end

  fun || (x as T { bytes = bytesX, bits = bitsX }, y as T { bytes = bytesY, ... }) =
    let
      val bits_xy = length x + length y
      val bytes = Array.array (bits_xy div W.wordSize +
                                (if bits_xy mod W.wordSize <> 0 then 1 else 0), 0w0)
    in
      Array.copy { di = 0, dst = bytes, src = bytesX };
      if bitsX = 0 then
        Array.copy { di = Array.length bytesX, dst = bytes, src = bytesY }
      else
        let
          val lenX = Array.length bytesX
          val lenY = Array.length bytesY
          fun mask n = W.<< (0w1, Word.fromInt n) - 0w1
          val word = Word.fromInt
        in
          Array.appi (fn (i,e) =>
            let
              val e' = bytes // (lenX - 1 + i)
            in
              bytes := (lenX - 1 + i,
                W.orb (e',
                  W.<< (W.andb (e, mask (W.wordSize - bitsX)), word bitsX)));
              if lenX + i < Array.length bytes then
                bytes := (lenX + i,
                  W.>> (W.andb (e, W.<< (mask bitsX, word (W.wordSize - bitsX)))
                       , word (W.wordSize - bitsX)))
              else ()
            end) bytesY
        end;
      T { bytes = bytes, bits = bits_xy mod W.wordSize }
    end

  fun |+| (x as T { bytes = bytesX, bits = bitsX }, y as T { bytes = bytesY, ... }) =
    if length x <> length y then
      raise Size
    else
      let
        val bytes = Array.tabulate (Array.length bytesX, fn n =>
                      W.xorb (bytesX // n,
                              bytesY // n))
      in
        T { bytes = bytes, bits = bitsX }
      end

  local
    structure IO = TextIO
    structure Cvt = StringCvt
  in
  fun dump (out, T { bytes, bits }) =
    let
      fun out' ss = IO.output (out, ss)
    in
      for 0 (fn i => i < Array.length bytes) inc (fn i =>
        ( out' (Cvt.padLeft #"0" 2 (W.fmt Cvt.HEX (Array.sub (bytes, i))));
          out' (if i mod 16 = 15 then "\n" else " ")
        )
      );
      out' "\n";
      IO.flushOut out
    end
  end (* local *)
end


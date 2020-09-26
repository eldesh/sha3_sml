
structure Keccak =
struct
  open ForLoop
  structure State = State
  structure Arr   = StateArray

  exception InvalidSizeState of State.t

  infix 4 ||
  val op|| = BitArray.||

  infix 4 |+|
  val op|+| = BitArray.|+|

  (**
   * A flag toggles whether this module outputs intermediate values or not.
   *)
  val debug = ref false

  (**
   * debug dump
   *)
  fun dump label x =
    if !debug then
      (
        print (label ^ "\n");
        Arr.dump (TextIO.stdOut, x)
      )
    else
      ()

  (**
   * the 1st algorithm of step mappings: theta
   *
   * §3.2.1 Algorithm 1: theta(A)
   *
   * @params state
   * @param state
   *)
  fun step_mapping_theta A =
    let
      val w = State.w (Arr.toState A)
      val C = Array2.array (5, w, Bit.O)
      val D = Array2.array (5, w, Bit.O)
    in
      (* step 1. *)
      for 0 (fn x => x < 5) inc (fn x =>
        for 0 (fn z => z < w) inc (fn z =>
          Array2.update (C, x, z,
            foldl Bit.xor Bit.O [
              Arr.sub (A, x, 0, z),
              Arr.sub (A, x, 1, z),
              Arr.sub (A, x, 2, z),
              Arr.sub (A, x, 3, z),
              Arr.sub (A, x, 4, z)
            ])
        )
      );
      (* step 2. *)
      for 0 (fn x => x < 5) inc (fn x =>
        for 0 (fn z => z < w) inc (fn z =>
          Array2.update (D, x, z,
            Bit.xor (
              Array2.sub (C, (x - 1) mod 5, z),
              Array2.sub (C, (x + 1) mod 5, (z - 1) mod w)))
        )
      );
      (* step 3. *)
      for 0 (fn x => x < 5) inc (fn x =>
        for 0 (fn y => y < 5) inc (fn y =>
          for 0 (fn z => z < w) inc (fn z =>
            Arr.update (A, x, y, z,
              Bit.xor (
                Arr.sub (A, x, y, z),
                Array2.sub (D, x, z)))
          )
        )
      )
    end

  (**
   * the 2nd algorithm of step mappings: rho
   *
   * §3.2.2 Algorithm 2: rho(A)
   * The effect of rho is to rotate the bits of each lane by a length, called the <i>offset</i>,
   * which depends on the fixed x and y coordinates of the lane.
   *
   * @params state
   * @param state
   *)
  fun step_mapping_rho A =
    let
      val w = State.w (Arr.toState A)
      (* step 1. *)
      val A' = Arr.fromState (State.fromArray (BitArray.array (Arr.size A)))
      val () = for 0 (fn z => z < w) inc (fn z =>
                 Arr.update (A', 0, 0, z, Arr.sub (A, 0, 0, z)))
      (* step 2. *)
      val (x, y) = (ref 1, ref 0)
    in
      (* step 3. *)
      for 0 (fn t => t <= 23) inc (fn t =>
        (
          (* step 3.a *)
          for 0 (fn z => z < w) inc (fn z =>
            Arr.update (A', !x, !y, z,
              Arr.sub (A, !x, !y, (z - (t+1) * (t+2) div 2) mod w))
          );
          (* step 3.b *)
          let val (x', y') = (!y, (2 * !x + 3 * !y) mod 5) in
            x := x';
            y := y'
          end
        )
      );
      BitArray.copy { src = State.toArray (Arr.toState A')
                    , dst = State.toArray (Arr.toState A ) }
    end

  (**
   * the 3rd algorithm of step mappings: pi
   *
   * §3.2.3 Algorithm 3: pi(A)
   * The effect of pi is to rearrange the positions of the lanes.
   *
   * @params state
   * @param state
   *)
  fun step_mapping_pi A =
    let
      val w = State.w (Arr.toState A)
      val A' = Arr.fromState (State.fromArray (BitArray.array (Arr.size A)))
    in
      (* step 1. *)
      for 0 (fn x => x < 5) inc (fn x =>
        for 0 (fn y => y < 5) inc (fn y =>
          for 0 (fn z => z < w) inc (fn z =>
            Arr.update (A', x, y, z,
              Arr.sub (A, (x + 3 * y) mod 5, x, z))
          )
        )
      );
      (* step 2. *)
      BitArray.copy { src = State.toArray (Arr.toState A')
                    , dst = State.toArray (Arr.toState A ) }
    end
 
  (**
   * the 4th algorithm of step mappings: chi
   *
   * §3.2.4 Algorithm 4: chi(A)
   * The effect of chi is to XOR each bit with a non-linear function of two other bits in its row.
   *
   * @params state
   * @param state
   *)
  fun step_mapping_chi A =
    let
      val w = State.w (Arr.toState A)
      val A' = Arr.fromState (State.fromArray (BitArray.array (Arr.size A)))
    in
      (* step 1. *)
      for 0 (fn x => x < 5) inc (fn x =>
        for 0 (fn y => y < 5) inc (fn y =>
          for 0 (fn z => z < w) inc (fn z =>
            Arr.update (A', x, y, z,
              Bit.xor (Arr.sub (A, x, y, z),
                       Bit.andb (Bit.xor (Arr.sub (A, (x + 1) mod 5, y, z), Bit.I),
                                 Arr.sub (A, (x + 2) mod 5, y, z))))
          )
        )
      );
      (* step 2. *)
      BitArray.copy { src = State.toArray (Arr.toState A')
                    , dst = State.toArray (Arr.toState A ) }
    end
 
  (**
   * §2.3 Basic Operations and Functions / Trunc_s(X)
   * For a positive integer s and a string X, Trunc_s(X) is the string comprised
   * of bits X[0] to X[s-1]. For example, Trunc_2(10100) = 10.
   *
   * @params s X
   * @param s positive integer
   * @param X bit string
   * @return X[0..s-1]
   *)
  fun Trunc s X =
    let
      val X' = BitArray.array s
    in
      for 0 (fn i => i < s) inc (fn i =>
        BitArray.update (X', i, BitArray.sub (X, i))
      );
      X'
    end

  fun pow2 n =
    if n < 0 then
      raise Domain
    else
      let val p = ref 1 in
        for 0 (fn i => i < n) inc
          (fn i => p := !p * 2);
        !p
      end

  (**
   * the 5th algorithm of step mappings: iota
   *
   * §3.2.5 Algorithm 6: iota(A)
   * The effect of iota is to modify some of the bits of Lane(0, 0) in a manner that depends on the round index <i>ir</i>.
   * The other 24 lanes are not affected by iota.
   *
   * @params ir state
   * @param ir round index
   * @param state
   *)
  fun step_mapping_iota ir A =
    let
      val l = State.l (Arr.toState A)
      (** Algorithm 5: rc(t)
       * @params t
       * @param t integer t.
       * @return bit rc(t).
       *)
      fun rc t =
        if t mod 255 = 0 then
          Bit.I
        else
          let
            fun sub (x, n) =
              if Word32.andb (x, Word32.<< (0w1, n)) <> 0w0
              then Bit.I else Bit.O

            fun update (x, n, b) =
              case b
                of Bit.I => Word32.orb (x,              Word32.<< (0w1, n))
                 | Bit.O => Word32.andb(x, Word32.notb (Word32.<< (0w1, n)))

            val R: Word32.word ref = ref 0wx01
          in
            for 1 (fn i => i <= t mod 255) inc (fn i =>
              let val R8 = sub (!R, 0w7) in
                (* step 3.a *)
                R := Word32.<< (!R, 0w1);
                (* step 3.b *)
                R := update (!R, 0w0, Bit.xor (sub(!R, 0w0), R8));
                (* step 3.c *)
                R := update (!R, 0w4, Bit.xor (sub(!R, 0w4), R8));
                (* step 3.d *)
                R := update (!R, 0w5, Bit.xor (sub(!R, 0w5), R8));
                (* step 3.e *)
                R := update (!R, 0w6, Bit.xor (sub(!R, 0w6), R8));
                (* step 3.f *)
                R := Word32.andb (!R, 0wxFF)
              end);
            sub (!R, 0w0)
          end
      val w = State.w (Arr.toState A)
      val timer = Measure.start ()
      (* step 1. *)
      (* step 2. *)
      val RC = BitArray.array w
    in
      (* step 3. *)
      for 0 (fn j => j <= l) inc (fn j =>
        BitArray.update (RC, pow2 j - 1, rc (j + 7 * ir))
      );
      Measure.check "Iota: step3:" timer;
      (* step 4. *)
      for 0 (fn z => z < w) inc (fn z =>
        Arr.update (A, 0, 0, z,
          Bit.xor (Arr.sub (A, 0, 0, z), BitArray.sub (RC, z)))
      );
      Measure.check "Iota: step4:" timer
    end

  (**
   * The transformation that results from applying the
   * step mappings Θ, ρ, π, χ, ι, in that order.
   *
   * §3.3 round function
   * Rnd(A, ir) = iota(chi(pi(rho(theta(A)))), ir)
   *
   * @params A ir
   * @param A  a state array.
   * @param ir a round index.
   *)
  fun Rnd A ir =
    let
      val timer = Measure.start ()
      val A' = Arr.clone A
    in
      step_mapping_theta   A';
      dump "After Theta:"  A';
      Measure.check "Rnd: Theta:" timer;
      step_mapping_rho     A';
      dump "After Rho:"    A';
      Measure.check "Rnd:   Rho:" timer;
      step_mapping_pi      A';
      dump "After Pi:"     A';
      Measure.check "Rnd:    Pi:" timer;
      step_mapping_chi     A';
      dump "After Chi:"    A';
      Measure.check "Rnd:   Chi:" timer;
      step_mapping_iota ir A';
      dump "After Iota:"   A';
      Measure.check "Rnd:  Iota:" timer;
      A'
    end

  (**
   * KECCAK-p permutations
   *
   * §3.3 KECCAK-p[b, nr] permutation consists of <i>nr</i> iterations of Rnd.
   * Algorithm 7: KECCAK-p[b, nr](S).
   *
   * <p>
   * The KECCAK-p permutation with nr rounds and width b is denoted by <i>KECCAK-p[b, nr]</i>.
   * And the permutation is defined for any b in {25, 50, 100, 200, 400, 800, 1600} and any positive integer nr.
   * </p>
   *
   * @params b nr S
   * @param b  length of string S.
   * @param S  string S of length b.
   * @param nr number of rounds nr.
   * @return S' of length b.
   *)
  fun keccak_p b nr S =
    let
      val timer = Measure.start ()
      val () = if b <> State.length S then raise InvalidSizeState S else ()
      val l = State.l S
      (* step 1. *)
      val A = ref (Arr.fromState S)
      val () = Measure.check "keccak_p: step1:" timer
    in
      (* step 2. *)
      for (12 + 2*l - nr) (fn ir => ir <= 12 + 2*l - 1) inc (fn ir =>
        (
         if !debug then print(concat["Round #", Int.toString ir, "\n"]) else ();
         A := Rnd (!A) ir
        )
      );
      Measure.check "keccak_p: step2:" timer;
      (* step 3 and 4. *)
      Arr.toState (!A)
    end

  local
    structure B = BitArray
  in
  (**
   * Sponge function
   *
   * Algorithm 8: SPONGE[f, pad, r](N, d)
   *
   * @params f pad r N d
   * @param f mapping function for strings of fixed length b.
   * @param pad
   * @param r rate (1600-c(bits)).
   * @param N string N.
   * @param d nonnegative integer.
   *          determines the number of bits that this function returns.
   * @return string Z such that len(Z) = d.
   *)
  fun sponge (f,b) pad r N d =
    let
      val () = if !debug then (print "sponge:\n"; BitArray.dump (TextIO.stdOut, N))
               else ()
      val len = B.length
      val timer = Measure.start ()
      (* step 1. *)
      val P = N || (pad r (len N))
      (* step 2. *)
      val n = len P div r
      (* step 3. *)
      val c = b - r
      (* step 4. *)
      val Pn = Vector.tabulate (n, fn i => B.range (P, i*r, r))
      (* step 5. *)
      val S = ref (B.array b)
      val () = Measure.check "sponge: step5:" timer
      (* step 6. *)
      val () =
        for 0 (fn i => i < n) inc (fn i =>
          S := f (!S |+| (Vector.sub (Pn, i) || (B.array c))))
      val () = Measure.check "sponge: step6:" timer
      (* step 7. *)
      val Z = ref (B.array 0)
      val continue = ref true
    in
      while !continue do (
        (* step 8. *)
        Z := !Z || (Trunc r (!S));
        (* step 9. *)
        if d <= B.length (!Z) then
          ( Z := Trunc d (!Z);
            continue := false )
        else
          (* step 10. *)
          S := f (!S);
        Measure.check "sponge: step10:" timer
      );
      !Z
    end
  end (* local *)

  local
    structure B = BitArray
  in
  (**
   * Padding function
   *
   * §5.1 Specification of pad10*1
   * Algorithm 9: pad10*1(x, m)
   *
   * @params x m
   * @param x positive integer.
   * @param m non-negative integer.
   * @return string P such that m + len(P) is a positive multiple of x.
   *)
  fun pad10s1 x m =
    let
      val () = if x <= 0 then raise Subscript else ()
      val () = if m < 0 then raise Subscript else ()
      val ` = B.fromVector o vector
      (* step 1. *)
      val j = (~m - 2) mod x
    in
      (* step 2. *)
      `[Bit.I] || B.array j || `[Bit.I]
    end
  end (* local *)

  (**
   * Specialized SPONGE and KECCAK-p functions
   *
   * §5.2 Specification of KECCAK[c]
   *
   * @params c N d
   * @param c capacity (c = 2d).
   * @param N input string.
   * @param d
   *)
  fun keccak c =
    let
      val (from, to) = (State.fromArray, State.toArray)
    in
      sponge (to o keccak_p 1600 24 o from, 1600) pad10s1 (1600 - c)
    end

  local
    val ` = BitArray.fromVector o vector
  in
  (**
   * SHA3-224
   * SHA-3 hash function is defined from the KECCAK[c] function.
   *
   * @param M A given message.
   *)
  fun sha3_224 M =
    keccak 448 (M || `[Bit.O, Bit.I]) 224

  (**
   * SHA3-256
   *
   * @param M A given message.
   *)
  fun sha3_256 M =
    keccak 512 (M || `[Bit.O, Bit.I]) 256

  (**
   * SHA3-384
   *
   * @param M A given message.
   *)
  fun sha3_384 M =
    keccak 768 (M || `[Bit.O, Bit.I]) 384

  (**
   * SHA3-512
   *
   * @param M A given message.
   *)
  fun sha3_512 M =
    keccak 1024 (M || `[Bit.O, Bit.I]) 512

  end (* local *)

end


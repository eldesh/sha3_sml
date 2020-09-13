
structure Sha3 =
struct
  open ForLoop
  structure State = State
  structure Arr   = StateArray

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
        for 0 (fn z => z < w) inc (fn z =>
          (
           (* step 3.a *)
           Arr.update (A', !x, !y, z,
             Arr.sub (A, !x, !y, (z - (t+1) * (t+2) div 2) mod w));
           (* step 3.b *)
           let val (x', y') = (!y, (2 * !x + 3 * !y) mod 5) in
             x := x';
             y := y'
           end
          )
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
   * @param s
   * @param X
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
       * @result bit rc(t).
       *)
      fun rc t =
        if t mod 255 = 0 then
          Bit.I
        else
          let
            val ` = BitArray.fromVector o vector
            val sub = BitArray.sub
            val R = ref (`[ Bit.I, Bit.O, Bit.O, Bit.O
                          , Bit.O, Bit.O, Bit.O, Bit.O ])
          in
            for 1 (fn i => i <= t mod 255) inc (fn i =>
              (
               (* step 3.a *)
               R := BitArray.|| (!R, `[Bit.O]);
               BitArray.update (!R, 0, Bit.xor (sub(!R, 0), sub(!R, 8)));
               BitArray.update (!R, 4, Bit.xor (sub(!R, 4), sub(!R, 8)));
               BitArray.update (!R, 5, Bit.xor (sub(!R, 5), sub(!R, 8)));
               BitArray.update (!R, 6, Bit.xor (sub(!R, 6), sub(!R, 8)));
               R := Trunc 8 (!R)
              )
            );
            sub (!R, 0)
          end
      val w = State.w (Arr.toState A)
      (* step 1. *)
      val A' = Arr.clone A
      (* step 2. *)
      val RC = BitArray.fromVector (Vector.tabulate (w, fn _ => Bit.O))
    in
      (* step 3. *)
      for 0 (fn j => j < l) inc (fn j =>
        BitArray.update (RC, pow2 j - 1, rc (j + 7 * ir))
      );
      (* step 4. *)
      for 0 (fn z => z < w) inc (fn z =>
        Arr.update (A', 0, 0, z,
          Bit.xor (Arr.sub (A, 0, 0, z),
                   BitArray.sub (RC, z)))
      );
      BitArray.copy { src = State.toArray (Arr.toState A')
                    , dst = State.toArray (Arr.toState A ) }
    end

  (**
   * §3.3 round function
   * Rnd(A, ir) = iota(chi(pi(rho(theta(A)))), ir)
   *)
  fun Rnd A ir =
    let
      val A' = Arr.clone A
    in
      step_mapping_theta   A';
      step_mapping_rho     A';
      step_mapping_pi      A';
      step_mapping_chi     A';
      step_mapping_iota ir A';
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
   * @params S nr
   * @param S  string S of length b.
   * @param nr number of rounds nr.
   * @result S' of length b.
   *)
  fun keccak_p S nr =
    let
      val l = State.l S
      (* step 1. *)
      val A = ref (Arr.fromState S)
    in
      (* step 2. *)
      for (12 + 2*l - nr) (fn ir => ir <= 12 + 2*l - 1) inc (fn ir =>
        A := Rnd (!A) ir
      );
      (* step 3 and 4. *)
      Arr.toState (!A)
    end

end


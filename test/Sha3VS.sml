
structure Sha3VS =
struct
  structure IO = TextIO.StreamIO
  structure SS = Substring
  structure Case = struct
    type t = { msg: Word8.word vector * int, digest: string }
  end

  type ('r, 's) reader = ('r, 's) StringCvt.reader

  fun bind  NONE    _ = NONE
    | bind (SOME x) f = f x

  fun satisfy2_scan pred f rdr s =
    case rdr s
      of SOME (e, s') => if pred e then SOME (f e, s') else NONE
       | NONE         => NONE

  fun satisfy_scan pred =
    satisfy2_scan pred (fn x=>x)

  fun char c =
    satisfy_scan (fn c' => c = c)

  fun int r =
    Int.scan StringCvt.DEC r

  fun list pred rdr s =
    case rdr s
      of SOME (e, s') =>
           if pred e then
             case list pred rdr s'
               of SOME (xs, s'') => SOME(e::xs, s'')
                | NONE           => SOME([e], s')
           else
             SOME ([], s)
       | NONE => NONE

  fun skip_comment r s =
    bind (r s) (fn (line, s') =>
      if String.isPrefix "#" line then
        skip_comment r s' (* before print(concat["skip: ", line]) *)
      else
        SOME ((), s))

  fun skip_blank_line r s = 
    bind (list (fn line => line = "\r\n") r s) (fn (line, s) => 
    SOME ((* print ".. skip blank line ..\n" *) (), s))

  fun kind_of_bit bit =
    case bit
      of 224 => SOME Sha3Kind.Sha3_224
       | 256 => SOME Sha3Kind.Sha3_256
       | 384 => SOME Sha3Kind.Sha3_384
       | 512 => SOME Sha3Kind.Sha3_512
       | _   => NONE

  fun scan_kind r s =
    bind (satisfy2_scan (String.isPrefix "[L = ")
                        (fn s => String.extract (s, 4, NONE)) r s)
                        (fn (line, s) =>
    bind (int       SS.getc (SS.full line)) (fn (bit, s') =>
    bind (char #"]" SS.getc s')             (fn (  _, s') =>
    bind (kind_of_bit bit) (fn kind =>
    SOME (kind, s)))))

  fun seq p q r s =
    bind (p r s) (fn (x, s) =>
    bind (q r s) (fn (y, s) =>
    SOME ((x, y), s)))

  fun split n ss =
    let
      val size = size ss
      val () = if size mod n <> 0 then raise Domain else ()
    in
      Vector.tabulate(size div n, fn i => String.substring (ss, i * n, 2))
    end

  local
    structure S = String
  in
  fun scan_len r s =
    bind (satisfy2_scan (S.isPrefix "Len = ")
                        (fn x => S.extract (x, 6, NONE)) r s)
                        (fn (len_line, s) =>
    Option.map
      (fn x => (x, s))
      (Int.fromString len_line))

  (* trim control chars from the right end of a string *)
  fun trimr ss =
    let val (l, _) = SS.splitr Char.isCntrl (SS.full ss)
    in SS.string l
    end

  fun scan_msg len r s =
    bind (satisfy2_scan (S.isPrefix "Msg = ")
                        (fn x => S.extract (x, 6, SOME (len div 8 * 2))) r s)
                        (fn (msg_line, s) =>
    let
      val msgs = split 2 (trimr msg_line)
    in
      SOME (Vector.map (valOf o Word8.fromString) msgs, s)
    end)

  fun scan_md r (s: 's) : (string * 's) option =
    bind (satisfy2_scan (S.isPrefix "MD = " )
                        (fn x => S.extract (x, 5, NONE)) r s)
                        (fn (md_line , s) =>
    SOME (trimr md_line, s))

  fun scan_case r s =
    bind (skip_blank_line r s) (fn (  _, s) =>
    bind (scan_len        r s) (fn (len, s) =>
    bind (scan_msg    len r s) (fn (msg, s) =>
    bind (scan_md         r s) (fn (md , s) =>
    SOME ({ msg = (msg, len mod 8), digest = md }, s)
    ))))
  end (* local *)

  fun read_file path f =
    let
      val file = TextIO.openIn path
    in
      f file handle e => (TextIO.closeIn file; raise e)
    end

  fun parse path : Sha3Kind.t * Case.t list =
    read_file path (fn file =>
    let
      val strm = TextIO.getInstream file
      val line = IO.inputLine
      fun tt _ = true
      val SOME (kind, cases) =
        bind (skip_comment    line strm)     (fn (   _, strm) =>
        bind (skip_blank_line line strm)     (fn (   _, strm) =>
        bind (scan_kind       line strm)     (fn (kind, strm) =>
        bind (list tt (scan_case line) strm) (fn (  cs, strm) =>
        bind (skip_blank_line line strm)     (fn (   _, strm) =>
        if IO.endOfStream strm
        then SOME (kind, cs)
        else NONE)))))
    in
      (kind, cases)
    end)

end

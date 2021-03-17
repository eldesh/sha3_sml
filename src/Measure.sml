(**
 * Measurement module for profiling hash functions.
 *)
structure Measure =
struct
  type t = Timer.cpu_timer

  fun start () =
    Timer.startCPUTimer ()

  fun check label t =
    let val { nongc, gc } = Timer.checkCPUTimes t in
      print (label ^ " ");
      check_usr_sys "nongc" nongc;
      print " ";
      check_usr_sys    "gc"    gc;
      print "\n"
    end

  and check_usr_sys label { usr, sys } =
    let val fmt = Time.fmt 5 in
      print(concat[label, " usr: ", fmt usr, " sys: ", fmt sys])
    end 
end


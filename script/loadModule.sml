(**
 * For Poly/ML:
 * If the module fails to load, it will display the path it was trying to load.
 *)
fun loadModule path =
  PolyML.loadModule path
  handle exn =>
    (print ("Failed to load the module: " ^ path ^ "\n");
     raise exn
    )

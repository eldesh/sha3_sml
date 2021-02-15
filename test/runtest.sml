
(* dummy structure for executing unit tests *)
structure z = struct
  val z = Sha3Test.main (CommandLine.name(), CommandLine.arguments())
end


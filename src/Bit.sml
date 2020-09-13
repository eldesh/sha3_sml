
structure Bit =
struct
  datatype t = O | I
  fun toInt O = 0
    | toInt I = 1

  fun fromInt 0 = O
    | fromInt 1 = I
    | fromInt n = raise Domain

  fun orb  (O, O) = O
    | orb  (_, _) = I

  fun andb (I, I) = I
    | andb (_, _) = O

  fun xor (O, I) = I
    | xor (I, O) = I
    | xor (_, _) = O
end


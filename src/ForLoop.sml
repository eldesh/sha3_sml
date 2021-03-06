
structure ForLoop =
struct
  fun inc x = x + 1

  fun for i cond step body =
    let
      fun for' i =
        if cond i then 
          (body i;
           for' (step i))
        else
          ()
    in
      for' i
    end

  fun for' i cond =
    for i cond inc
end


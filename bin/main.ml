open Edsl

(* let simp = "let x = 5" *)

(* let prog = {|
  let prog = typescript:
    let x = `{5 + 5};
    let y = 17;
  tsend|} *)

(* let ts = {|
  let ts = typescript:
    let x = 5
  tsend
|} *)

(* let prog = "let x = typescript: 5 tsend" *)

let ts = "let x = typescript: let x = {{let y = typescript: 5 end}} end"

let () = Util.evaluate_e ts

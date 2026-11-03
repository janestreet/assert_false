(* [pretty_LOC] pulls apart a string produced by __LOC__, and reassembles it into the more
   familiar FILE:LINE:COL format.

   __LOC__ is preferred over [%here], to ensure that as little code as possible is
   produced at the call site. [%here] expands into a record allocation, so this helps to
   avoid tipping the flambda scales compared to [assert false].
*)
let pretty_LOC loc =
  match
    Scanf.sscanf_opt
      loc
      "File %S, line %d, characters %d-%d"
      (fun file line column (_ : int) -> Printf.sprintf "%s:%d:%d" file line column)
  with
  | Some pretty -> pretty
  | None ->
    (* failsafe in case our parsing logic ever breaks *)
    loc
;;

let pretty_pos (here : Lexing.position) =
  let file = here.pos_fname in
  let lnum = here.pos_lnum in
  let cnum = here.pos_cnum - here.pos_bol in
  Printf.sprintf "%s:%d:%d" file lnum cnum
;;

let[@cold] bug ~__LOC__:loc uuid =
  failwith (Printf.sprintf "BUG: %s at %s" uuid (pretty_LOC loc))
;;

let[@cold] bug' ~(here : [%call_pos]) uuid =
  failwith (Printf.sprintf "BUG: %s at %s" uuid (pretty_pos here))
;;

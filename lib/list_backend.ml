open Sexplib.Std
open Ppx_compare_lib.Builtin

type ('key, 'value) t = ('key * 'value) list ref
[@@deriving sexp, compare]

let create () = ref []
let add t k v = t := (k, v) :: !t
let delete t k = t := List.remove_assoc k !t

let modify t k v =
  let rec aux = function
    | [] -> raise Not_found
    | (k', _) :: tl -> if k = k' then (k, v) :: tl else aux tl
  in
  t := aux !t

let iter t f = List.iter f !t
let filter t f = List.filter f !t
let to_assoc_list t = !t

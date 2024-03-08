type ('key, 'value) t = ('key * 'value) list ref

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

let pp_header ppf =
  let open Format in
  let pp_spaces ppf spaces = pp_print_break ppf spaces 0 in
  fprintf ppf "%aKey%a" pp_set_tab () pp_spaces 3;
  let rec aux headers =
    match headers with
    | [] -> print_tab ()
    | h :: tl ->
        fprintf ppf "%a%s%a" pp_set_tab () h pp_spaces 15;
        aux tl
  in
  aux

let pp headers pp_k pp_v ppf (t : ('key, 'value) t) =
  let open Format in
  let pp_kv ppf (k, v) = fprintf ppf "%a%a%a" pp_k k pp_print_tab () pp_v v in
  open_tbox ();
  pp_header ppf headers;
  pp_print_list ~pp_sep:pp_print_tab pp_kv ppf !t;
  close_tbox ();
  print_newline ()

include Tabs_intf

(* module Table = struct *)
(*   type ('key, 'value) t = ('key * 'value) list ref *)

(*   let create () = ref [] *)
(*   let add t k v = t := (k, v) :: !t *)
(*   let delete t k = t := List.remove_assoc k !t *)

(*   let modify t k v = *)
(*     let rec aux = function *)
(*       | [] -> raise Not_found *)
(*       | (k', _) :: tl -> if k = k' then (k, v) :: tl else aux tl *)
(*     in *)
(*     t := aux !t *)

(*   let iter t f = List.iter f !t *)

(*   let pp_header ppf = *)
(*     let open Format in *)
(*     let pp_spaces ppf spaces = pp_print_break ppf spaces 0 in *)
(*     fprintf ppf "%aKey%a" pp_set_tab () pp_spaces 3; *)
(*     let rec aux headers = *)
(*       match headers with *)
(*       | [] -> print_tab () *)
(*       | h :: tl -> *)
(*           fprintf ppf "%a%s%a" pp_set_tab () h pp_spaces 15; *)
(*           aux tl *)
(*     in *)
(*     aux *)

(*   let pp headers pp_k pp_v ppf (t : ('key, 'value) t) = *)
(*     let open Format in *)
(*     let pp_kv ppf (k, v) = fprintf ppf "%a%a%a" pp_k k pp_print_tab () pp_v v in *)
(*     open_tbox (); *)
(*     pp_header ppf headers; *)
(*     pp_print_list ~pp_sep:pp_print_tab pp_kv ppf !t; *)
(*     close_tbox (); *)
(*     print_newline () *)
(* end *)
module Make (B : BACKEND_TYPE) = struct
  type user = { id : int; name : string; email : string } [@@deriving make]
  type date = Ptime.date
  type id = int

  let pp_date ppf date =
    let day, month, year = date in
    Format.fprintf ppf "%d/%d/%d" day month year

  type split = Amt of (user * float) list | Percentage of (user * float) list

  type entry = { added_by : user; amt : float; date : date; split : split }
  [@@deriving make]

  let pp_entry_tab ppf entry =
    let open Format in
    let pp_split_terse ppf split =
      let pp_print_split_pair ppf (user, v) =
        fprintf ppf "%s:%.2f" user.name v
      in
      match split with
      | Amt l ->
          fprintf ppf "($):[%a]"
            (pp_print_list ~pp_sep:pp_print_space pp_print_split_pair)
            l
      | Percentage l ->
          fprintf ppf "(%%):[%a]"
            (pp_print_list ~pp_sep:pp_print_space pp_print_split_pair)
            l
    in
    fprintf ppf "%s" entry.added_by.name;
    print_tab ();
    fprintf ppf "%a" pp_date entry.date;
    print_tab ();
    fprintf ppf "%.2f" entry.amt;
    print_tab ();
    fprintf ppf "%a" pp_split_terse entry.split;
    print_tab ()

  type key = int
  type t = { keygen : int Gen.gen; users : user list; tab : (id, entry) B.t }

  let create users = { keygen = Gen.init Fun.id; users; tab = B.create () }

  let add_expense t entry =
    let key = Gen.next t.keygen |> Option.get in
    B.add t.tab key entry

  let delete_expense t key = B.delete t.tab key
  let modify_expense t key new_entry = B.modify t.tab key new_entry

  let show t : unit =
    let open Format in
    set_margin 200;
    let headers = [ "added by"; "date"; "amt"; "split" ] in
    printf "%a" (B.pp headers pp_print_int pp_entry_tab) t.tab
end

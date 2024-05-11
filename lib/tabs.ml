include Tabs_intf
open Ppx_compare_lib.Builtin
open Sexplib.Std

module Ptime = struct
  include Ptime

  let date_of_sexp =
    let open Sexplib.Conv in
    triple_of_sexp int_of_sexp int_of_sexp int_of_sexp

  let sexp_of_date =
    let open Sexplib.Conv in
    sexp_of_triple sexp_of_int sexp_of_int sexp_of_int

  let compare_date d1 d2 =
    let t1 = of_date d1 |> Option.get in
    let t2 = of_date d2 |> Option.get in
    compare t1 t2
end

module Make (B : BACKEND_S) = struct
  type user = { id : int; name : string; email : string }
  [@@deriving make, show { with_path = false }, sexp, compare]

  type date = Ptime.date [@@deriving sexp, compare]
  type id = int [@@deriving show, sexp, compare]

  let make_date ~day ~month ~year = (day, month, year)

  let pp_date ppf date =
    let day, month, year = date in
    Format.fprintf ppf "%d/%d/%d" day month year

  let show_date date =
    pp_date Format.str_formatter date;
    Buffer.contents Format.stdbuf

  type split = Amt of (user * float) list | Percentage of (user * float) list
  [@@deriving sexp, compare]

  type entry = {
    name : string;
    added_by : user;
    amt : float;
    date : date;
    split : split;
  }
  [@@deriving make, sexp, compare, fields ~getters]

  let show_amt = Format.sprintf "$%.2f"

  let pp_entry_tab ppf entry =
    let open Format in
    let pp_split_terse ppf split =
      let pp_print_split_pair ppf ((user, v) : user * float) =
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
    fprintf ppf "%s" entry.name;
    print_tab ();
    fprintf ppf "%s" entry.added_by.name;
    print_tab ();
    fprintf ppf "%a" pp_date entry.date;
    print_tab ();
    fprintf ppf "%.2f" entry.amt;
    print_tab ();
    fprintf ppf "%a" pp_split_terse entry.split;
    print_tab ()

  type t = {
    mutable key_counter : int;
    users : user list;
    tab : (id, entry) B.t;
  }
  [@@deriving sexp, compare]

  let create users = { key_counter = 0; users; tab = B.create () }

  let add_expense t entry =
    if not (List.mem entry.added_by t.users) then
      failwith "entry added by invalid user";
    let key = t.key_counter + 1 in
    t.key_counter <- key;
    B.add t.tab key entry

  let delete_expense t key = B.delete t.tab key
  let modify_expense t key new_entry = B.modify t.tab key new_entry

  let filter_expenses t ?added_by ?date name_op =
    match name_op with
    | None -> B.to_assoc_list t.tab
    | Some name ->
        B.filter t.tab (fun (_k, v) ->
            let x = Option.equal ( = ) added_by (Some v.added_by) in
            let y = Option.equal ( = ) date (Some v.date) in
            let z = name = v.name in
            x || y || z)

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

  let pp_table headers pp_k pp_v ppf assoc_l =
    let open Format in
    let pp_kv ppf (k, v) = fprintf ppf "%a%a%a" pp_k k pp_print_tab () pp_v v in
    open_tbox ();
    pp_header ppf headers;
    pp_print_list ~pp_sep:pp_print_tab pp_kv ppf assoc_l;
    close_tbox ();
    print_newline ()

  let show t : unit =
    let open Format in
    printf "Users:@[<v 2>@,@[%a@]@,@]@."
      (pp_print_list ~pp_sep:pp_print_cut pp_user)
      t.users;
    set_margin 200;
    let headers = [ "name"; "added by"; "date"; "amt"; "split" ] in
    printf "Table:@[<v 2>@,@[%a@]@]@."
      (pp_table headers pp_print_int pp_entry_tab)
      (B.to_assoc_list t.tab)

  let show_expenses e =
    let open Format in
    let headers = [ "name"; "added by"; "date"; "amt"; "split" ] in
    printf "Entries:@[<v 2>@,@[%a@]@]@."
      (pp_table headers pp_print_int pp_entry_tab)
      e
end

module Default_Tab = Make (List_backend)

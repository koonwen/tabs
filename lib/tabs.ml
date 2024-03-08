include Tabs_intf
module List_backend = List_backend

module Make (B : BACKEND_S) = struct
  type user = { id : int; name : string; email : string } [@@deriving make]
  type date = Ptime.date
  type id = int

  let make_date ~day ~month ~year = (day, month, year)

  let pp_date ppf date =
    let day, month, year = date in
    Format.fprintf ppf "%d/%d/%d" day month year

  type split = Amt of (user * float) list | Percentage of (user * float) list

  type entry = {
    name : string;
    added_by : user;
    amt : float;
    date : date;
    split : split;
  }
  [@@deriving make]

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

  let filter_expenses t ?added_by ?date name =
    B.filter t.tab (fun (k, v) ->
        let x = Option.equal ( = ) added_by (Some v.added_by) in
        let y = Option.equal ( = ) date (Some v.date) in
        let z = name = v.name in
        x || y || z)

  let show t : unit =
    let open Format in
    set_margin 200;
    let headers = [ "added by"; "date"; "amt"; "split" ] in
    printf "%a" (B.pp headers pp_print_int pp_entry_tab) t.tab
end

open Containers

type date = int * int * int

type split =
  | All
  | Amt of (Telegram.Api.User.user * float) list
  | Percentage of (Telegram.Api.User.user * float) list

type entry = {
  id : int;
  date : date;
  name : string;
  amt : float;
  entered_by : Telegram.Api.User.user;
  split : split;
}
[@@deriving make]

type t = entry list

let make () = []
let add t entry = t @ entry
let del t idx = List.remove_at_idx idx t
let write _channel : unit = failwith "Not implemented"
let read _str : t = failwith "Not implemented"

let show t =
  let open Format in
  let pp_date ppf (d, m, y) = fprintf ppf "%d/%d/%d" d m y in
  let pp_entry ppf ent =
    fprintf ppf "@[%d: [%a] '%s' %.2f @]" ent.id pp_date ent.date ent.name
      ent.amt
  in
  printf "@[<v>%a@]@." (pp_print_list ~pp_sep:pp_print_cut pp_entry) t

let%expect_test "show" =
  let user1 = Telegram.Api.User.create ~id:1 ~first_name:"Koon" () in
  let user2 = Telegram.Api.User.create ~id:2 ~first_name:"Joel" () in
   let entry1 =
    make_entry ~id:1 ~date:(1, 1, 2024) ~name:"lunch" ~amt:20.0
      ~entered_by:user1 ~split:All
  in
  let entry2 =
    make_entry ~id:2 ~date:(2, 1, 2024) ~name:"dinner" ~amt:10.0
      ~entered_by:user2 ~split:(Amt [user1, 7.0; user2, 3.0])
  in
  let t = [ entry1; entry2 ] in
  show t;
  [%expect "
    1: [1/1/2024] 'lunch' 20.00
    2: [2/1/2024] 'dinner' 10.00"]

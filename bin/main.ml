open Tabs
module Tab = Make (List_backend)

let user1 = Tab.make_user ~id:1 ~name:"kw" ~email:"blah"
let user2 = Tab.make_user ~id:2 ~name:"xr" ~email:"blah"
let user3 = Tab.make_user ~id:3 ~name:"jl" ~email:"blah"
let t = Tab.create [ user1; user2; user3 ]

let () =
  let entry1 =
    Tab.make_entry ~name:"breakfast" ~added_by:user1 ~amt:10.0 ~date:(1, 1, 2024)
      ~split:(Amt [ (user1, 5.0); (user2, 5.0) ])
  in
  let entry2 =
    Tab.make_entry ~name:"lunch" ~added_by:user2 ~amt:20.0 ~date:(1, 1, 2024)
      ~split:(Percentage [ (user1, 50.0); (user2, 50.0) ])
  in
  let entry3 =
    Tab.make_entry ~name:"dinner" ~added_by:user3 ~amt:100.0 ~date:(1, 1, 2024)
      ~split:(Amt [ (user1, 40.0); (user2, 50.0); (user3, 10.0) ])
  in
  let entry4 =
    Tab.make_entry ~name:"breakfast" ~added_by:user1 ~amt:10.0 ~date:(2, 1, 2024)
      ~split:(Amt [ (user1, 5.0); (user2, 5.0) ])
  in
  let entry5 =
    Tab.make_entry ~name:"lunch" ~added_by:user2 ~amt:20.0 ~date:(2, 1, 2024)
      ~split:(Percentage [ (user1, 50.0); (user2, 50.0) ])
  in
  let entry6 =
    Tab.make_entry ~name:"dinner" ~added_by:user3 ~amt:100.0 ~date:(2, 1, 2024)
      ~split:(Amt [ (user1, 40.0); (user2, 50.0); (user3, 10.0) ])
  in
  List.iter
    (fun e -> Tab.add_expense t e)
    [ entry1; entry2; entry3; entry4; entry5; entry6 ];
  Tab.show t;

  Format.printf "Get all breakfast\n";
  let breakfast_only = Tab.filter_expenses t "breakfast" in
  Tab.show_expenses breakfast_only

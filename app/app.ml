[@@@warning "-32"]

open Core
open Incr_dom
module Tab = Tabs.Default_Tab

module Model = struct
  type t = { tab : Tab.t; input : string } [@@deriving fields, sexp, compare]

  let cutoff t1 t2 = compare t1 t2 = 0
end

module State = struct
  type t = unit
end

module Action = struct
  type t = Update of string [@@deriving sexp]

  let apply_action action _state ~schedule_action:_ =
    match action with Update s -> Model.{ tab = Tab.create []; input = s }
end

let initial_model : Model.t = { tab = Tab.create []; input = "" }
let on_startup ~schedule_action:_ _model = Async_kernel.return ()


let table =
  let open Vdom in
  Node.table
    [
      Node.thead
        [
          Node.tr
            [
              Node.th [ Node.text "Date" ];
              Node.th [ Node.text "Expense" ];
              Node.th [ Node.text "Amount" ];
            ];
        ];
      Node.tbody [];
    ]

let create model ~old_model:_ ~inject =
  let open Incr.Let_syntax in
  let open Vdom in
  let%map view =
    let%map text = model >>| Model.input in
    let submission =
      Node.div
        [
          Node.text "Add an expense";
          Node.input
            ~attrs:
              [
                Attr.type_ "text";
                Attr.string_property "value" text;
                Attr.on_input (fun _ev text -> inject (Action.Update text));
              ]
            ();
          Node.button [ Node.text "Update" ];
          Node.text text;
          table;
        ]
    in
    Node.body [ submission ]
  and model = model in
  (* Note that we don't include [on_display] or [update_visibility], since
     these are optional arguments *)
  Component.create ~apply_action:Action.apply_action model view

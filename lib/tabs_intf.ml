(** Expense Tab

    APIs for creating new Tabs and adding/deleting/modifying user
    expense inputs.
*)

(* The core data structure interface used to store tabs *)
module type BACKEND_S = sig
  type ('key, 'value) t

  val create : unit -> ('key, 'value) t
  val add : ('key, 'value) t -> 'key -> 'value -> unit
  val delete : ('key, 'value) t -> 'key -> unit
  val modify : ('key, 'value) t -> 'key -> 'value -> unit
  val iter : ('key, 'value) t -> ('key * 'value -> unit) -> unit

  val filter :
    ('key, 'value) t -> ('key * 'value -> bool) -> ('key * 'value) list

  val to_assoc_list : ('key, 'value) t -> ('key * 'value) list
end

module type MAKE_S = functor (B : BACKEND_S) -> sig
  type t
  (** Abstract type of the Tab backend. implementation to be decided, irmin/sqlite  *)

  type user
  type date = Ptime.date

  val make_user : id:int -> name:string -> email:string -> user
  val make_date : day:int -> month:int -> year:int -> date

  type id
  type entry

  type split =
    | Amt of (user * float) list
    | Percentage of (user * float) list
        (** Represents how an expense should be split between involved users *)

  val make_entry :
    name:string ->
    added_by:user ->
    amt:float ->
    date:date ->
    split:split ->
    entry

  val create : user list -> t
  val add_expense : t -> entry -> unit
  val delete_expense : t -> id -> unit
  val modify_expense : t -> id -> entry -> unit

  val filter_expenses :
    t -> ?added_by:user -> ?date:date -> string -> (id * entry) list

  val show : t -> unit
  val show_expenses : (id * entry) list -> unit
end

module type Intf = sig
  module type BACKEND_S = BACKEND_S

  module List_backend : BACKEND_S
  module Make : MAKE_S
end

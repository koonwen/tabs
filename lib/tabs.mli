(** Expense Tab

    APIs for creating new Tabs and adding/deleting/modifying user
    expense inputs.
*)

module Table : sig
  type ('key, 'value) t

  val create : unit -> ('key, 'value) t
  val add : ('key, 'value) t -> 'key -> 'value -> unit
  val delete : ('key, 'value) t -> 'key -> unit
  val modify : ('key, 'value) t -> 'key -> 'value -> unit
  val iter : ('key, 'value) t -> ('key * 'value -> unit) -> unit
end

type t
(** Abstract type of the Tab backend. implementation to be decided, irmin/sqlite  *)

type user

val make_user : id:int -> name:string -> email:string -> user

type date = Ptime.date

type split =
  | Amt of (user * float) list
  | Percentage of (user * float) list
      (** Represents how an expense should be split between involved users *)

type key
type entry

val make_entry : added_by:user -> amt:float -> date:date -> split:split -> entry
val create : user list -> t
val add_expense : t -> entry -> unit
val delete_expense : t -> key -> unit
val modify_expense : t -> key -> entry -> unit
val show : t -> unit

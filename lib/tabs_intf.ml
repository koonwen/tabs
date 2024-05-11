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

  val t_of_sexp :
    (Sexplib0.Sexp.t -> 'key) ->
    (Sexplib0.Sexp.t -> 'value) ->
    Sexplib0.Sexp.t ->
    ('key, 'value) t

  val sexp_of_t :
    ('key -> Sexplib0.Sexp.t) ->
    ('value -> Sexplib0.Sexp.t) ->
    ('key, 'value) t ->
    Sexplib0.Sexp.t

  val compare :
    ('key -> 'key -> int) ->
    ('value -> 'value -> int) ->
    ('key, 'value) t ->
    ('key, 'value) t ->
    int
end

module type TAB_S = sig
  type t
  (** Abstract type of the Tab backend. implementation to be decided, irmin/sqlite  *)

  type user
  type date = Ptime.date

  val make_user : id:int -> name:string -> email:string -> user
  val make_date : day:int -> month:int -> year:int -> date
  val show_date : date -> string

  type id

  val show_id : id -> string

  type entry

  type split =
    | Amt of (user * float) list
    | Percentage of (user * float) list
        (** Represents how an expense should be split between involved users *)

  val name : entry -> string
  val added_by : entry -> user
  val amt : entry -> float
  val date : entry -> date
  val split : entry -> split

  val show_amt: float -> string

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

  (* Providing an empty string returns all the entries *)
  val filter_expenses :
    t -> ?added_by:user -> ?date:date -> string option -> (id * entry) list

  val show : t -> unit
  val show_expenses : (id * entry) list -> unit
  val t_of_sexp : Sexplib0.Sexp.t -> t
  val sexp_of_t : t -> Sexplib0.Sexp.t
  val compare : t -> t -> int
end

module type MAKE_S = functor (_ : BACKEND_S) -> TAB_S

module type Intf = sig
  module type BACKEND_S = BACKEND_S

  module Make : MAKE_S
  module Default_Tab : TAB_S
end

type item =
    | Wall
    | Ground
    | Enemy
    | Orb
    | BigOrb
    | Player
    | Fruit

type t

(* Load the map from the data file *)
val load : string -> bool

(* Load the map from given map, only use in test *)
val load_from_data : item array array ref -> unit

val reload : unit -> unit

val get_size : unit -> (float * float)

(* Get the item at given coordination *)
val get_location : (float * float) -> item

(* Update the item at given coordination *)
val change_location : (float * float) -> item -> unit

(* Count item number in the map *)
val get_item_count: item -> int

val find_player : unit -> (float * float) option

val find_enemies : unit -> (float * float) list

val find_fruits : unit -> (float * float) list

val find_random_empty : unit -> (float * float) option

val remove_player : unit -> unit

val remove_enemies : unit -> unit

val remove_fruits : unit -> unit
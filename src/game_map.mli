type item =
    | Wall
    | Ground
    | Enemy
    | Orb
    | BigOrb
    | Player
    | Fruit

(* Load the map from the data file *)
val load : string -> bool

val get_size : unit -> (float * float)

(* Get the item at given coordination *)
val get_location : (float * float) -> item

(* Update the item at given coordination *)
val change_location : (float * float) -> item -> unit

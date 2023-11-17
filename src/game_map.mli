open Core

type item =
    | Wall of int
    | Ground
    | Enemy
    | Player
    | Fruit

type t

(* Load the map from the data file *)
val load : string -> t option

(* Get the item at given coordination *)
val get_location : (float * float) -> item

(* Update the item at given coordination *)
val change_location : (float * float) -> item -> t

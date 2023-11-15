open Core

type item =
    | Wall of int
    | Ground
    | Enemy
    | Player

type t

val load : string -> t Option.t

val get_location : (float * float) -> item

val change_location : (float * float) -> item -> t

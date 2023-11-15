open Core

type fruit_type = 
    | Apple
    | Cherry
    | Grape

type t

val create : (float * float) -> fruit_type -> t

val update : t -> t Option.t

val get_pos : t -> (float * float)

val get_sprite: t -> (int * int)
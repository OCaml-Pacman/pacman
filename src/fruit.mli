open Core

type fruit = {
    mutable position : (int * int);
    sprite : (int * int);
}

type fruit_type = 
    | Apple
    | Cherry
    | Grape

type t = fruit

val create : (float * float) -> fruit_type -> t

val update : t -> t Option.t

val get_pos : t -> (float * float)

val get_sprite: t -> (int * int)

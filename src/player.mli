open Graphics

type t

type key = 
| Up | Down | Left | Right | Action | Pause

val create : (float * float) -> t

val update : t -> Game_state.t -> t option

val check_alive : t -> Game_state.t -> bool

val get_sprite : t -> (int * int)
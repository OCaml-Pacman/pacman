type t = Objects.player

type key = 
| Up | Down | Left | Right | Action | Pause

let create (loc : (float * float)) : t 

val update : t -> Game_state.t -> t option

val get_pos : t -> (float * float)

val check_alive : t -> Game_state.t -> bool

val get_sprite : t -> (int * int)

type t

(* type key =
   | Up | Down | Left | Right | Action | Pause *)
type player_state
type direction
type key

val create : float * float -> t
val update : t -> key -> t
val check_alive : t -> bool
val get_sprite : t -> int * int

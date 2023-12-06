type player_state = Alive | Dead
type direction = Up | Down | Left | Right
type key = None | Key of char

type t = {
  mutable position : float * float;
  mutable player_state : player_state;
  mutable move_counter : int;
  mutable move_direction : direction;
  mutable sprite : int * int;
}


val create : float * float -> t
val update : t -> key -> t
val check_alive : t -> bool
val get_sprite : t -> int * int

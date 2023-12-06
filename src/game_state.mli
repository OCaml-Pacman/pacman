type t

(* Update the game state for one frame *)
val update : char option -> t -> t

(* Load a game level *)
val new_game: unit -> t

val get_player : t -> Player.t

val get_enemies : t -> Enemy.enemy list

val get_fruits : t -> Fruit.t list
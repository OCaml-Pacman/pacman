type t

(* Update the game state for one frame *)
val update : t -> t

(* Load a game level *)
val new_game: Game_map.t -> t

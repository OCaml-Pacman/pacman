open Core
(* open Game_state *)
open Graphics

val sprite_sheet : Graphics.image

val game_state : Game_sate.t

(* Draw a sprite on canvas *)
val draw_sprite : (int * int) -> unit

(* Update the whole game screen for one frame *)
val update : game_state -> unit

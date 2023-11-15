open Core
open GameState
open Graphics

val sprite_sheet : Graphics.image

val game_state : GameSate.t

val draw_sprite : (int * int) -> uint

val update : uint -> uint
(** This module defines functions for rendering sprites and maps in a game environment. *)

val resize_ratio : int
(** The resize ratio for the game, determined the window size **)

(** [draw_sprite sprite_pos screen_pos] draws a sprite at position [sprite_pos] on the canvas at screen position [screen_pos]. *)
val draw_sprite : ?transp: bool -> (int * int) -> (int * int) -> unit

(** [draw_map ()] renders the entire game map on the canvas. *)
val draw_map: unit -> unit

(** [load_sprite filename] loads the sprite from the file specified by [filename]. 
    Returns [true] if successful, otherwise [false]. *)
val load_sprite : string -> bool

(** [set_res ()] sets the resolution for rendering. *)
val set_res : unit -> unit

(** [coord_map2screen map_pos] converts map coordinates [map_pos] to screen coordinates. 
    Returns the screen coordinates as an integer pair. *)
val coord_map2screen : (float * float) -> (int * int)

(** This method will draw the current score on screen **)
val draw_score : int -> unit

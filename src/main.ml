(* open Core *)
open Stdlib


let () = Graphics.open_graph " 800x600"
let rec game_loop state =

  let key = 
    if Graphics.key_pressed() 
    then Some (Graphics.read_key())
    else None
  in
  let new_state = Game_state.update key state in
  (* Render.render new_state; render time *)
  game_loop new_state


let main () =
  let initial_state = Game_state.new_game  in
  Graphics.open_graph " 800x600";
  try
    game_loop initial_state
  with
  | Graphics.Graphic_failure "fatal I/O error" ->
      Graphics.close_graph ()  (* Close graphics window if an error occurs *)
  | e -> 
      Graphics.close_graph ();  (* Ensure that the graphics window is closed in case of any error *)
      raise e

(* Start the game *)
let () = main ()
      
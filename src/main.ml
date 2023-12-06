(* open Core *)
open Stdlib

let rec game_loop state =

  let key = 
    if Graphics.key_pressed() 
    then Some (Graphics.read_key())
    else None
  in
  let new_state = Game_state.update key state in
  Render.draw_map ();
  Game_state.get_enemies new_state |> List.iter ((fun (e :Enemy.enemy) ->
    Render.draw_sprite e.sprite @@ Render.coord_map2screen e.position ));
  Game_state.get_fruits new_state |> List.iter (fun (f :Fruit.t) ->
    Render.draw_sprite f.sprite @@ Render.coord_map2screen f.position );
  let p = Game_state.get_player new_state in
  Render.draw_sprite p.sprite @@ Render.coord_map2screen p.position;
  Unix.sleepf 0.04;
  game_loop new_state


let main () =
  if Game_map.load "map.csv" && Render.load_sprite "sprite.png" then
    let initial_state = Game_state.new_game ()  in
    Graphics.open_graph "";
    Render.set_res ();
    try
      game_loop initial_state
    with
    | Graphics.Graphic_failure "fatal I/O error" ->
        Graphics.close_graph ()  (* Close graphics window if an error occurs *)
    | e -> 
        Graphics.close_graph ();  (* Ensure that the graphics window is closed in case of any error *)
        raise e
  else
    failwith "Failed to Load resources"

(* Start the game *)
let () = main ()
      
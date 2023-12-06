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
  Game_state.get_enemies new_state |> List.iter (fun (e :Enemy.enemy) ->
    let (rx, ry) = e.position in
    let x = Float.mul rx 16. |> Float.to_int in
    let y = Float.mul ry 16. |> Float.to_int in
    Render.draw_sprite e.sprite (x, y) );
  Game_state.get_fruits new_state |> List.iter (fun (f :Fruit.t) ->
    let (rx, ry) = f.position in
    let x = Float.mul rx 16. |> Float.to_int in
    let y = Float.mul ry 16. |> Float.to_int in
    Render.draw_sprite f.sprite (x, y) );
  let p = Game_state.get_player new_state in
  let (rx, ry) = p.position in
  let x = Float.mul rx 16. |> Float.to_int in
  let y = Float.mul ry 16. |> Float.to_int in
  Render.draw_sprite p.sprite (x, y);
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
      
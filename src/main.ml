open Core

let rec game_loop state =
  let key =
    if Graphics.key_pressed () then Some (Graphics.read_key ()) else None
  in
  (* Create New state *)
  let new_state = Game_state.update key state in
  (match Game_state.get_state new_state with
  | Active ->
      (* Draw Basemap *)
      Render.draw_map ();
      (* Draw enemies *)
      Game_state.get_enemies new_state
      |> List.iter ~f:(fun (e : Enemy.enemy) ->
             Render.draw_sprite e.sprite @@ Render.coord_map2screen e.position);
      Game_state.get_fruits new_state
      |> List.iter ~f:(fun (f : Fruit.t) ->
             Render.draw_sprite f.sprite @@ Render.coord_map2screen f.position);
      (* Draw Player *)
      let p = Game_state.get_player new_state in
      Render.draw_sprite p.sprite @@ Render.coord_map2screen p.position;
      Graphics.set_color Graphics.white;
      Graphics.moveto 0 0;
      (* Draw Score *)
      Game_state.get_score new_state
      |> Printf.sprintf "Score: %d" |> Graphics.draw_string
  | Win ->
      (* Clear graph *)
      Graphics.clear_graph ();
      Graphics.set_color Graphics.foreground;
      (* Draw results *)
      Graphics.moveto 0 0;
      Graphics.draw_string "Press any key to continue ...";
      (match Graphics.text_size "Press any key to continue ..." with
      | _, y -> Graphics.moveto 0 y);
      Game_state.get_score new_state
      |> Printf.sprintf "You Win! Score: %d"
      |> Graphics.draw_string
  | Lose ->
      (* Clear graph *)
      Graphics.clear_graph ();
      Graphics.set_color Graphics.foreground;
      Graphics.moveto 0 0;
      (* Draw results *)
      Graphics.draw_string "Press any key to continue ...";
      (match Graphics.text_size "Press any key to continue ..." with
      | _, y -> Graphics.moveto 0 y);
      Game_state.get_score new_state
      |> Printf.sprintf "You Lose! Score: %d"
      |> Graphics.draw_string);

  (* Show on display sleep and run next iter *)
  Graphics.synchronize ();
  Caml_unix.sleepf 0.04;
  game_loop new_state

let main ~map_file ~sprite_file =
  (* Disable auto sync *)
  Graphics.auto_synchronize false;
  (* Setup Stderr to show result*)
  Stdlib.Out_channel.set_buffered Stdlib.stderr false;
  (* Set window*)
  Graphics.set_window_title "Ocaml PacMan";
  (* Load files *)
  if Game_map.load map_file && Render.load_sprite sprite_file then (
    let initial_state = Game_state.new_game () in
    Render.set_res ();
    try game_loop initial_state with
    | Graphics.Graphic_failure "fatal I/O error" ->
        Graphics.close_graph () (* Close graphics window if an error occurs *)
    | e ->
        Graphics.close_graph ();
        (* Ensure that the graphics window is closed in case of any error *)
        raise e)
  else failwith "Failed to Load resources"

(* Start the game *)
let () =
  Command.basic_spec ~summary:"Start the PacMan with specified map and sprite files"
    Command.Spec.(
      empty
      +> flag "-map"
           (optional_with_default "map.csv" string)
           ~doc:"FILE Specify the map file (default: \"map.csv\")"
      +> flag "-sprite"
           (optional_with_default "sprite.png" string)
           ~doc:"FILE Specify the sprite file (default: \"sprite.png\")")
    (fun map_file sprite_file () -> main ~map_file ~sprite_file)
  |> Command_unix.run ~version:"0.1a" ~build_info:"R1"

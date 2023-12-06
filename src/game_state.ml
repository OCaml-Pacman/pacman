open Enemy
open Fruit
open Player
open Game_map
open Core

type state = Active | Win | Lose

type t = {
  mutable player : Player.t;
  mutable enemys : enemy list;
  mutable score : int;
  mutable state : state;
  mutable enemy_scared : bool;
  mutable enemy_scared_timer : int;
  fruits : Fruit.t list;
}

let get_player (state:t) : Player.t =
  state.player
let get_enemies (state:t) : enemy list =
  state.enemys
let get_fruits (state:t) : Fruit.t list =
  state.fruits

(*
  player获取输入更新位置（输入，当前player，map）
  enemy获取状态，检查变成逃的时间，时间结束重制状态，寻路，更新位置，（当前player，当前enemy，map）
  比player和所有enemy，如果碰到，enemy在逃，enemy死，否则，player死，更新score
  比Player和所有的大豆，如果碰到，enemy变成逃
  加分
  渲染
*)

let init_game_state (player : Player.t) (fruits : Fruit.t list)
    (enemys : enemy list) =
  {
    player;
    fruits;
    enemys;
    score = 0;
    state = Active;
    enemy_scared = false;
    enemy_scared_timer = 0;
  }

(* the inital coordinates to put the game objects *)
(* let init_pos_player = (0.0, 0.0)
let init_pos_fruits = (20.0, 20.0)
let init_pos_enemy = (50.0, 50.0) *)
let enemy_scared_time = 200

(* (** [check_key key_char] checks if the given char [key_char] is a valid
       movement. *)
   let check_key (key_char: char) : bool =
     match key_char with
     | 'a' | 'w' | 's' | 'd' -> true
     | _ -> false *)

(* get the scores when the ghost is eaten *)
let get_ghost_score (ghosts_eaten : enemy_type) : int =
  match ghosts_eaten with
  | Red -> 200
  | Blue -> 400
  | Orange -> 800
  | Pink -> 1600

let get_enemy_update (enemy : enemy) (player_pos : float * float) : enemy =
  match enemy.enemy_type with
  | Red -> Red_enemy.update enemy player_pos
  | Blue -> Blue_enemy.update enemy player_pos
  | Orange -> Orange_enemy.update enemy player_pos
  | Pink -> Pink_enemy.update enemy player_pos

let new_game () =
  Printf.eprintf "New game\n";
  Out_channel.flush stdout;
  Game_map.reload ();
  (* let (rx, ry) = Game_map.get_size () in *)
  let new_player = Player.create @@ (Game_map.find_player () |> Option.value_exn) in
  let new_enemy = Game_map.find_enemies () |>  List.map ~f:(fun pos -> Red_enemy.create pos) in
  let new_fruits = Game_map.find_fruits () |> List.map ~f:(fun pos -> Fruit.create pos Cherry) in
  Game_map.remove_player (); Game_map.remove_fruits(); Game_map.remove_enemies ();
  init_game_state new_player new_fruits new_enemy

(*[check_overlap user_pos ghost] will return true if the distance between the
  player position [user_pos] and the center of the ghost [ghost] are less
  than a distance amount, and false otherwise. *)
let check_enemy_overlap (player_pos : float * float) (enemy : enemy) : bool =
  let enemy_pos = enemy.position in
  let ghost_x = fst enemy_pos in
  let ghost_y = snd enemy_pos in
  let user_x = fst player_pos in
  let user_y = snd player_pos in
  let check_distance = 1.0 in
  Float.( <= ) (Float.abs (ghost_x -. user_x)) check_distance
  && Float.( =. ) user_y ghost_y
  || Float.( <= ) (Float.abs (ghost_y -. user_y)) check_distance
     && Float.( =. ) user_x ghost_x

(* check whether enemy and player meet and update the state correspondingly *)
let check_enemy_state (cur_player : Player.t) (cur_enemy : enemy)
    (cur_state : t) =
  let enemy_overlap = check_enemy_overlap cur_player.position cur_enemy in
  match (enemy_overlap, cur_enemy.enemy_state) with
  | true, Active -> cur_player.player_state <- Player.Dead
  | false, Active -> ()
  | true, Scared ->
      cur_enemy.enemy_state <- Dead;
      cur_state.score <- cur_state.score + get_ghost_score cur_enemy.enemy_type
  | false, Scared -> ()
  | _, Dead -> ()

(* check whether the current position has object, normal object will add one points to total score.
   Big object will change enemy to scared state *)
let check_object_overlap (cur_player : Player.t) (cur_state : t) =
  let (px,py) = cur_player.position in
  let judgeP = (Float.add px 0.5, Float.add py 0.5) in
  let obj = Game_map.get_location judgeP in
  match obj with
  | Orb ->
      cur_state.score <- cur_state.score + 1;
      change_location judgeP Ground
  | BigOrb ->
      cur_state.enemys
      |> List.iter ~f:(fun enemy -> enemy.enemy_state <- Scared);
      cur_state.enemy_scared <- true;
      change_location judgeP Ground
  | _ -> ()

(* check whether the current position has object, normal object will add one points to total score.
   Big object will change enemy to scared state *)

let check_fruit_overlap (player_pos : float * float) (fruit : Fruit.t) : bool =
  let fruit_pos = fruit.position in
  let ghost_x = fst fruit_pos in
  let ghost_y = snd fruit_pos in
  let user_x = fst player_pos in
  let user_y = snd player_pos in
  let check_distance = 1.0 in
  Float.( <= ) (Float.abs (ghost_x -. user_x)) check_distance
  && Float.( =. ) user_y ghost_y
  || Float.( <= ) (Float.abs (ghost_y -. user_y)) check_distance
     && Float.( =. ) user_x ghost_x

let check_fruit_state (player : Player.t) (fruit : Fruit.t) =
  if check_fruit_overlap player.position fruit then fruit.fruit_state <- Eaten
  else ()

(* Transfer the Some/None type to Key/None type *)
let trans_key_option input_key =
  match input_key with Some v -> Key v | None -> None

(* check the timeout of scared enemy *)
let check_scared_time_state cur_state =
  if cur_state.enemy_scared then (
    cur_state.enemy_scared_timer <- cur_state.enemy_scared_timer + 1;
    if cur_state.enemy_scared_timer > enemy_scared_time then (
      cur_state.enemy_scared_timer <- 0;
      cur_state.enemy_scared <- false);
    cur_state)
  else (
    cur_state.enemys |> List.iter ~f:(fun enemy -> enemy.enemy_state <- Active);
    cur_state)

let check_win cur_state =
  if Game_map.get_item_count Orb = 0 then (
    cur_state.state <- Win;
    cur_state)
  else cur_state


let update_active input_key cur_state =
  let cur_player = cur_state.player in
  let cur_enemys = cur_state.enemys in
  (* check overlap between enemy and player and update game state *)
  List.iter cur_enemys ~f:(fun enemy ->
      check_enemy_state cur_player enemy cur_state);
  List.iter cur_state.fruits ~f:(fun fruit ->
      check_fruit_state cur_player fruit);
  check_object_overlap cur_player cur_state;
  if check_alive cur_player then (
    (* update enemy should happen before update player since the enmey needs player previous movement *)
    let next_enemys =
      List.map cur_enemys ~f:(fun enemy ->
          get_enemy_update enemy cur_player.position)
    in
    let key = trans_key_option input_key in
    let next_player = Player.update cur_player key in
    cur_state.player <- next_player;
    cur_state.enemys <- next_enemys)
  else cur_state.state <- Lose;
  cur_state

let update (input_key : char option) (current_state : t)  : t =
  let current_state = check_scared_time_state current_state in
  let current_state = check_win current_state in
  match current_state.state with
  | Active -> update_active input_key current_state
  | Lose -> new_game ()
  | Win -> new_game ()

open Core

type player_state = Alive | Dead
type direction = Up | Down | Left | Right
type key = None | Key of char

type t = {
  mutable position : float * float;
  mutable player_state : player_state;
  mutable move_counter : int;
  mutable move_direction : direction;
  mutable sprite : int * int;
}


let player_speed = 0.08
let player_sprite_num = 3
(* let string_of_player_state = function Alive -> "Alive" | Dead -> "Dead"

let string_of_direction = function
  | Up -> "Up"
  | Down -> "Down"
  | Left -> "Left"
  | Right -> "Right"

let string_of_player record =
  let position_str =
    Printf.sprintf "(%f, %f)" (fst record.position) (snd record.position)
  in
  let player_state_str = string_of_player_state record.player_state in
  let move_counter_str = string_of_int record.move_counter in
  let move_direction_str = string_of_direction record.move_direction in
  let sprite_str =
    Printf.sprintf "(%d, %d)" (fst record.sprite) (snd record.sprite)
  in
  Printf.sprintf
    "{ position: %s; player_state: %s; move_counter: %s; move_direction: %s; \
     sprite: %s }\n"
    position_str player_state_str move_counter_str move_direction_str sprite_str *)

let key_to_direction (key : key) : direction option =
  match key with
  | Key 'w' -> Some Up
  | Key 's' -> Some Down
  | Key 'a' -> Some Left
  | Key 'd' -> Some Right
  | _ -> None

let direction_to_delta (direction : direction) =
  match direction with
  | Up -> (0.0, -1.0)
  | Down -> (0.0, 1.0)
  | Left -> (-1.0, 0.0)
  | Right -> (1.0, 0.0)

let add_position (p1 : float * float) (p2 : float * float) : float * float =
  (fst p1 +. (fst p2 *. player_speed), snd p1 +. (snd p2 *. player_speed))

(* let float_mod (x : float) (y : float) : float =
  x -. (y *. Float.round_down (x /. y)) *)

(* let get_in_map_position (position : float * float) : float * float =
  let x_max, y_max = Game_map.get_size () in
  (float_mod (fst position) x_max, float_mod (snd position) y_max) *)

let update_sprite (player : t) : unit =
  match (player.move_direction, player.move_counter) with
  | Up, 0 -> player.sprite <- (2, 0)
  | Up, 1 -> player.sprite <- (1, 2)
  | Up, 2 -> player.sprite <- (0, 2)
  | Up, 3 -> player.sprite <- (1, 2)
  | Down, 0 -> player.sprite <- (2, 0)
  | Down, 1 -> player.sprite <- (1, 3)
  | Down, 2 -> player.sprite <- (0, 3)
  | Down, 3 -> player.sprite <- (1, 3)
  | Left, 0 -> player.sprite <- (2, 0)
  | Left, 1 -> player.sprite <- (1, 1)
  | Left, 2 -> player.sprite <- (0, 1)
  | Left, 3 -> player.sprite <- (1, 1)
  | Right, 0 -> player.sprite <- (2, 0)
  | Right, 1 -> player.sprite <- (1, 0)
  | Right, 2 -> player.sprite <- (0, 0)
  | Right, 3 -> player.sprite <- (1, 0)
  | _ -> failwith "invalid player move state"

let create (init_pos : float * float) : t =
  {
    position = init_pos;
    player_state = Alive;
    move_counter = 0;
    move_direction = Right;
    sprite = (0, 0);
  }

let check_collsion direction pos = 
  let (x,y) = pos in
  let (jx, jy) = (Float.add x 0.05, Float.add y 0.05) in
  let roundXPos = (Float.round x, y) in
  let roundYPos = (x, Float.round y) in
  let ul = Game_map.get_location (jx, jy) in
  let ur = Game_map.get_location (Float.add jx 0.90,jy) in
  let dl = Game_map.get_location (jx,Float.add jy 0.90) in
  let dr = Game_map.get_location (Float.add jx 0.90, Float.add jy 0.90) in
  match direction, ul, ur, dl, dr with
    | Up, Wall, _, _, _ -> roundYPos
    | Up, _, Wall, _, _ -> roundYPos
    | Down, _, _, Wall, _ -> roundYPos
    | Down, _, _, _, Wall -> roundYPos
    | Left, Wall, _, _, _ -> roundXPos
    | Right, _, Wall, _, _ -> roundXPos
    | Left, _, _, Wall, _ -> roundXPos
    | Right, _, _, _, Wall -> roundXPos
    | _ -> pos
  

let update (player : t) (key : key) : t =
  let direction =
    match key_to_direction key with
    | Some dir ->
        player.move_direction <- dir;
        dir
    | None -> player.move_direction
  in
  let new_pos = add_position player.position (direction_to_delta direction) in
  player.position <- check_collsion direction new_pos;
  player.move_counter <- (player.move_counter + 1) mod player_sprite_num;
  update_sprite player;
  (* print_endline (string_of_player player); *)
  player

let check_alive (player : t) : bool =
  match player.player_state with Alive -> true | Dead -> false

let get_sprite (player : t) : int * int = player.sprite

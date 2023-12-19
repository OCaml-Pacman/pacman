open Core
open Common

type player_state = Alive | Dead | Armed [@@deriving equal]
type direction = Common.direction
type key = None | Key of char
type fruit = Fruit.t

type t = {
  mutable position : float * float;
  mutable speed : float;
  mutable player_state : player_state;
  mutable move_counter : int;
  mutable move_direction : direction;
  mutable sprite : int * int;
  mutable fruits : fruit list;
  mutable fruit_bullet : Fruit.t option;
}

let player_speed = 0.08
let player_sprite_num = 4

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

let add_position (p1 : float * float) (p2 : float * float) (speed : float) :
    float * float =
  (fst p1 +. (fst p2 *. speed), snd p1 +. (snd p2 *. speed))

let float_mod (x : float) (y : float) : float =
  x -. (y *. Float.round_down (x /. y))

let get_in_map_position (position : float * float) : float * float =
  let x_max, y_max = Game_map.get_size () in
  (float_mod (fst position) x_max, float_mod (snd position) y_max)

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

let create ?(speed = player_speed) (init_pos : float * float) : t =
  {
    position = init_pos;
    speed;
    player_state = Alive;
    move_counter = 0;
    move_direction = Right;
    sprite = (0, 0);
    fruits = [];
    fruit_bullet = None;
  }

let check_collsion direction pos =
  let x, y = pos in
  let jx, jy = (Float.add x 0.05, Float.add y 0.05) in
  let roundXPos = (Float.round x, y) in
  let roundYPos = (x, Float.round y) in
  let roundPos = (Float.round x, Float.round y) in
  let ul = Game_map.get_location (jx, jy) in
  let ur = Game_map.get_location (Float.add jx 0.90, jy) in
  let dl = Game_map.get_location (jx, Float.add jy 0.90) in
  let dr = Game_map.get_location (Float.add jx 0.90, Float.add jy 0.90) in
  match (direction, ul, ur, dl, dr) with
  | Up, Wall, Wall, _, _ -> roundYPos
  | Up, Wall, _, _, _ -> roundPos
  | Up, _, Wall, _, _ -> roundPos
  | Down, _, Wall, Wall, _ -> roundYPos
  | Down, _, _, _, Wall -> roundPos
  | Down, _, _, Wall, _ -> roundPos
  | Left, Wall, _, Wall, _ -> roundXPos
  | Left, Wall, _, _, _ -> roundPos
  | Left, _, _, Wall, _ -> roundPos
  | Right, _, Wall, _, Wall -> roundXPos
  | Right, _, Wall, _, _ -> roundPos
  | Right, _, _, _, Wall -> roundPos
  | _ -> pos

let is_wall (pos : float * float) : bool =
  let pos1 = (fst pos +. 0.05, snd pos +. 0.05) in
  let pos2 = (fst pos +. 0.95, snd pos +. 0.95) in
  match (Game_map.get_location pos1, Game_map.get_location pos2) with
  | Wall, _ -> true
  | _, Wall -> true
  | _ -> false

let update_fruit_bullet (player : t) (key : key) =
  match (key, player.player_state) with
  | Key 'j', Armed -> (
      match player.fruits with
      | fruit :: tail ->
          let bullet_pos =
            add_position player.position
              (direction_to_delta player.move_direction)
              1.0
          in
          if not (is_wall bullet_pos) then (
            fruit.position <- bullet_pos;
            fruit.move_direction <- player.move_direction;
            fruit.fruit_state <- Bullet;
            player.fruit_bullet <- Some fruit;
            player.fruits <- tail;
            match tail with _ :: _ -> () | [] -> player.player_state <- Alive)
      | [] -> failwith "Player armed with no fruit")
  | _ -> ()

let update (player : t) (key : key) : unit =
  let direction =
    match key_to_direction key with
    | Some dir ->
        player.move_direction <- dir;
        dir
    | None -> player.move_direction
  in
  let new_pos =
    add_position player.position (direction_to_delta direction) player.speed
    |> get_in_map_position
  in
  player.position <- check_collsion direction new_pos;
  player.move_counter <- (player.move_counter + 1) mod player_sprite_num;
  update_sprite player;
  update_fruit_bullet player key

let check_alive (player : t) : bool =
  not (equal_player_state player.player_state Dead)

let get_sprite (player : t) : int * int = player.sprite

let eat_fruit (player : t) (fruit : fruit) =
  let x_max, _ = Game_map.get_size () in
  fruit.position <-
    (x_max -. 4.0 +. Float.of_int (List.length player.fruits), -1.0);
  player.fruits <- fruit :: player.fruits;
  player.player_state <- Armed

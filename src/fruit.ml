open Common

type fruit_type = Common.fruit_type
type fruit_state = Eaten | Left | Bullet
type direction = Common.direction

type fruit = {
  mutable position : float * float;
  speed : float;
  mutable move_direction : direction;
  mutable sprite : int * int;
  mutable fruit_type : fruit_type;
  mutable fruit_state : fruit_state;
  mutable hit_counter : int;
}

type t = fruit

let get_sprite_from_type (fruit_type : fruit_type) : int * int =
  match fruit_type with
  | Cherry -> (2, 3)
  | Strawberry -> (3, 3)
  | Orange -> (4, 3)

let get_speed_from_type (fruit_type : fruit_type) : float =
  match fruit_type with Cherry -> 0.24 | Strawberry -> 0.20 | Orange -> 0.16

let create (init_pos : float * float) (fruit : fruit_type) : t =
  let sprite_pos = get_sprite_from_type fruit in
  {
    position = init_pos;
    speed = get_speed_from_type fruit;
    move_direction = Up;
    fruit_state = Left;
    sprite = sprite_pos;
    fruit_type = fruit;
    hit_counter = 0;
  }

let get_sprite (fruit : t) : int * int = fruit.sprite

let direction_to_delta (direction : direction) =
  match direction with
  | Up -> (0.0, -1.0)
  | Down -> (0.0, 1.0)
  | Left -> (-1.0, 0.0)
  | Right -> (1.0, 0.0)

let add_position (p1 : float * float) (p2 : float * float) (speed : float) :
    float * float =
  (fst p1 +. (fst p2 *. speed), snd p1 +. (snd p2 *. speed))

let is_wall (pos : float * float) : bool =
  let pos1 = (fst pos +. 0.05, snd pos +. 0.05) in
  let pos2 = (fst pos +. 0.95, snd pos +. 0.95) in
  match (Game_map.get_location pos1, Game_map.get_location pos2) with
  | Wall, _ -> true
  | _, Wall -> true
  | _ -> false

let stick_to_wall (fruit : t) : unit =
  let x, y = fruit.position in
  let round_x_pos = (Float.round x, y) in
  let round_y_pos = (x, Float.round y) in
  match fruit.move_direction with
  | Up -> fruit.position <- round_y_pos
  | Down -> fruit.position <- round_y_pos
  | Left -> fruit.position <- round_x_pos
  | Right -> fruit.position <- round_x_pos

let get_new_empty_pos (fruit : t) : (float * float) option =
  let new_pos =
    add_position fruit.position
      (direction_to_delta fruit.move_direction)
      fruit.speed
  in
  if is_wall new_pos then None else Some new_pos

(** Simply disappear **)
let cherry_hit_wall (fruit : t) : unit = fruit.fruit_state <- Eaten

(** Turn back for at most 2 time **)
let strawberry_hit_wall (fruit : t) : unit =
  fruit.move_direction <- turn_back fruit.move_direction;
  fruit.hit_counter <- fruit.hit_counter + 1;
  if fruit.hit_counter > 2 then (
    fruit.fruit_state <- Eaten;
    fruit.hit_counter <- 0)

(** Try to turn left or right for at most 2 time **)
let orange_hit_wall (fruit : t) : unit =
  fruit.move_direction <- turn_right fruit.move_direction;
  (match get_new_empty_pos fruit with
  | Some new_pos -> fruit.position <- new_pos
  | None -> (
      fruit.move_direction <- turn_back fruit.move_direction;
      match get_new_empty_pos fruit with
      | Some new_pos -> fruit.position <- new_pos
      | None -> fruit.move_direction <- turn_left fruit.move_direction));
  fruit.hit_counter <- fruit.hit_counter + 1;
  if fruit.hit_counter > 5 then (
    fruit.fruit_state <- Eaten;
    fruit.hit_counter <- 0)

let handle_hit_wall (fruit : t) : unit =
  stick_to_wall fruit;
  match fruit.fruit_type with
  | Cherry -> cherry_hit_wall fruit
  | Strawberry -> strawberry_hit_wall fruit
  | Orange -> orange_hit_wall fruit

let update (fruit : t) : t =
  match fruit.fruit_state with
  | Eaten -> fruit
  | Left -> fruit
  | Bullet ->
      (match get_new_empty_pos fruit with
      | Some new_pos -> fruit.position <- new_pos
      | None -> handle_hit_wall fruit);
      fruit

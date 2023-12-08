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
}

type t = fruit

let get_sprite_from_type (fruit_type : fruit_type) : int * int =
  match fruit_type with
  | Cherry -> (2, 3)
  | Strawberry -> (3, 3)
  | Orange -> (4, 3)

let get_speed_from_type (fruit_type : fruit_type) : float =
  match fruit_type with Cherry -> 0.16 | Strawberry -> 0.20 | Orange -> 0.24

let create (init_pos : float * float) (fruit : fruit_type) : t =
  let sprite_pos = get_sprite_from_type fruit in
  {
    position = init_pos;
    speed = get_speed_from_type fruit;
    move_direction = Up;
    fruit_state = Left;
    sprite = sprite_pos;
    fruit_type = fruit;
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
  let pos2 = (fst pos +. 0.95, snd pos +. 0.95) in
  match (Game_map.get_location pos, Game_map.get_location pos2) with
  | Wall, _ -> true
  | _, Wall -> true
  | _ -> false

let update (fruit : t) : t =
  match fruit.fruit_state with
  | Eaten -> fruit
  | Left -> fruit
  | Bullet ->
      (let new_pos =
         add_position fruit.position
           (direction_to_delta fruit.move_direction)
           fruit.speed
       in
       if is_wall new_pos then fruit.fruit_state <- Eaten
       else fruit.position <- new_pos);
      fruit

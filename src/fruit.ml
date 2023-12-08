type fruit_type = Cherry | Strawberry | Orange [@@deriving equal]
type fruit_state = Eaten | Left | Bullet
type direction = Up | Down | Left | Right

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
  match fruit_type with Cherry -> 2.0 | Strawberry -> 3.0 | Orange -> 4.0

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

let update (fruit : t) : t =
  match fruit.fruit_state with
  | Eaten -> fruit
  | Left -> fruit
  | Bullet -> fruit

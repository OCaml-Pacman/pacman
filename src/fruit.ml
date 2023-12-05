type fruit_type = 
    | Cherry
    | Strawberry
    | Orange

type fruit_state = Eaten | Left

type fruit = {
  mutable position : (float * float);
  mutable sprite : (int * int);
  mutable fruit_type: fruit_type;
  mutable fruit_state: fruit_state;
}

type t = fruit


let create (init_pos : float * float) (fruit: fruit_type) : t =
  let sprite_pos = 
    match fruit with
    | Cherry -> (2, 3)
    | Strawberry ->  (2, 4)
    | Orange -> (2, 5)
  in
  {
    position = init_pos;
    fruit_state = Left;
    sprite = sprite_pos;
    fruit_type = fruit;
  }

let get_sprite (fruit: t) : (int * int) = 
  fruit.sprite

let update (fruit:t) : t = 
  match fruit.fruit_state with
  | Eaten -> fruit
  | Left -> fruit

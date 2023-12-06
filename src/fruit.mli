type fruit_type = 
    | Cherry
    | Strawberry
    | Orange

type fruit_state = Eaten | Left

type fruit = {
  mutable position : (float * float);
  mutable sprite : (int * int);
  mutable fruit_type: fruit_type;
  mutable fruit_state: fruit_state
}

type t = fruit

val create : (float * float) -> fruit_type -> t

val update : t -> t

val get_sprite: t -> (int * int)

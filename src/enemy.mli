type enemy_type =
| Red | Blue | Orange | Pink

type enemy = {
    mutable position : (int * int);
    mutable enemy_state : int;

    sprite : (int * int);
    enemy_type: enemy_type
}

module type MoveLogic = sig
  val move : (float * float) -> Game_state.t -> (float * float)
end

module type Enemy =
sig
  type t = enemy
  include MoveLogic
  
  val get_sprite : t -> (int * int)
  val get_pos : t -> (float * float)
  val create : (float * float) -> t
  val update : t -> Game_state.t -> t option
end

module MakeEnemy (_ : MoveLogic) : Enemy 


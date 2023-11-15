module type MoveLogic = sig
  val move : (float * float) -> Game_state.t -> (float * float)
end

module type Enemy =
sig
  type t 
  include MoveLogic
  
  val get_sprite : t -> (int * int)
  val get_pos : t -> (float * float)
  val create : (float * float) -> t
  val update : t -> Game_state.t -> t option
end

module MakeEnemy (_ : MoveLogic) : Enemy 

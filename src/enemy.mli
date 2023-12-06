type enemy_type = Red | Blue | Orange | Pink

type enemy_state = Active | Scared | Dead

type enemy = {
    mutable position : float * float;
    mutable enemy_state : enemy_state;
    mutable enemy_type: enemy_type;
    mutable move_counter : int;
    mutable move_direction : int;
    mutable sprite : int * int; 
    init_pos : float * float;
}

module type SetEnemyType = sig
  type t = enemy
  val move :  t -> (float * float) -> t
  val get_enemytype : enemy_type
  val get_sprite : (int * int) list list
end

module type Enemy =
sig
  type t = enemy
  val get_pos : t -> (float * float)
  val create : (float * float) -> t
  val update : t -> (float * float) -> t
end

module MakeEnemy (_ : SetEnemyType) : Enemy 

module Red_enemy : Enemy 

module Blue_enemy : Enemy 

module Orange_enemy : Enemy 

module Pink_enemy : Enemy 

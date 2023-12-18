(** This module defines types and modules for handling enemy entities in a game. *)

(** The [enemy_type] type represents the different types of enemies. *)
type enemy_type = Common.enemy_type


(** The [enemy_state] type represents the current state of an enemy. *)
type enemy_state = 
  | Active   (** Enemy is active. *)
  | Scared   (** Enemy is scared. *)
  | Dead     (** Enemy is dead. *)

(** The [enemy] type represents an enemy with various attributes. *)
type enemy = {
    mutable position : float * float;       (** The position of the enemy. *)
    mutable enemy_state : enemy_state;      (** The current state of the enemy. *)
    enemy_type: enemy_type;         (** The type of the enemy. *)
    mutable move_counter : int;             (** Counter for the enemy's movement. *)
    mutable move_direction : int;           (** Direction of the enemy's movement. *)
    mutable dead_timer : int;               (** The time since enemy dead **)
    mutable sprite : int * int;             (** Sprite position for the enemy. *)
    mutable speed: float;                   (** Current speed for the enemy. *)
    init_pos : float * float;               (** Initial position of the enemy. *)
}

(** [kill_enemy] will a let a enemy dead **)
val kill_enemy : enemy -> unit

(** [SetEnemyType] is a module type that defines operations on enemy types. *)
module type SetEnemyType = sig
  type t = enemy
  val move :  t -> (float * float) -> t    (** [move t pos] moves the enemy [t] to position [pos]. *)
  val get_enemytype : enemy_type           (** Returns the type of the enemy. *)
  val get_sprite : (int * int) list list   (** Returns the sprite of the enemy. *)
end

(** [Enemy] is a module type that defines basic operations on enemies. *)
module type Enemy =
sig
  type t = enemy
  val get_pos : t -> (float * float)       (** [get_pos t] returns the position of the enemy [t]. *)
  val create : (float * float) -> t        (** [create pos] creates a new enemy at position [pos]. *)
  val update : t -> (float * float) -> t   (** [update t pos] updates the enemy [t] with new position [pos]. *)
end

(** [MakeEnemy] is a functor that creates a new [Enemy] module given a [SetEnemyType] module. *)
module MakeEnemy (_ : SetEnemyType) : Enemy 

(** [Red_enemy] is a module for handling Red enemies. *)
module Red_enemy : Enemy 

(** [Blue_enemy] is a module for handling Blue enemies. *)
module Blue_enemy : Enemy 

(** [Orange_enemy] is a module for handling Orange enemies. *)
module Orange_enemy : Enemy 

(** [Pink_enemy] is a module for handling Pink enemies. *)
module Pink_enemy : Enemy 

val get_enemy_sprite_by_type : enemy_type -> int * int

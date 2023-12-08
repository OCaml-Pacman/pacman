(** This module defines the type and functions for managing the game state in a game. *)
open Enemy

(** State interface of the game *)
type state = Active | Win | Lose
(** The type [t] represents the game state. *)
type t = {
  mutable player : Player.t;
  mutable enemys : enemy list;
  mutable score : int;
  mutable state : state;
  mutable enemy_scared : bool;
  mutable enemy_scared_timer : int;
  mutable fruits : Fruit.t list;
}


(** [update input state] updates the game state [state] for one frame based on the optional input [input]. 
    Returns the updated game state. *)
val update : char option -> t -> t

(** [new_game ()] initializes a new game level and returns the initial game state. *)
val new_game: unit -> t

(** [get_player state] returns the player from the game state [state]. *)
val get_player : t -> Player.t

(** [get_enemies state] returns a list of enemies from the game state [state]. *)
val get_enemies : t -> Enemy.enemy list

(** [get_fruits state] returns a list of fruits from the game state [state]. *)
val get_fruits : t -> Fruit.t list

(** [get_score state] returns the current score from the game state [state]. *)
val get_score : t -> int

(** [get_state state] returns the current state from the game state [state]. *)
val get_state : t -> state 
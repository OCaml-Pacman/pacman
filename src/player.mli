(** This module defines types and functions for handling the player character in a game. *)

(** The [player_state] type represents the current state of the player. *)
type player_state =
  | Alive  (** Indicates the player is alive. *)
  | Dead  (** Indicates the player is dead. *)
  | Armed  (** Indicates the player is armed with fruit **)
[@@deriving equal]

type direction = Common.direction
(** The [direction] type represents the direction in which the player can move. *)

(** The [key] type represents a key input by the player, with [None] for no input or [Key] for a specific character. *)
type key =
  | None  (** Represents no key input. *)
  | Key of char  (** Represents a key input with a specific character. *)

type t = {
  mutable position : float * float;  (** The position of the player. *)
  mutable speed : float;  (** The move speed of player **)
  mutable player_state : player_state;  (** The current state of the player. *)
  mutable move_counter : int;  (** Counter for the player's movement. *)
  mutable move_direction : direction;
      (** The direction of the player's movement. *)
  mutable sprite : int * int;  (** Sprite position for the player. *)
  mutable fruits : Fruit.t list;
      (** The fruits that player currently have **)
  mutable fruit_bullet : Fruit.t option;
}
(** The [t] type represents a player with various attributes. *)

val create : ?speed:float -> float * float -> t
(** [create pos] creates a new player at the specified position [pos]. *)

val update : t -> key -> unit
(** [update player key] updates the player [player] based on the key input [key]. 
    Returns the updated player. *)

val check_alive : t -> bool
(** [check_alive player] checks if the player [player] is alive. 
    Returns [true] if alive, otherwise [false]. *)

val get_sprite : t -> int * int
(** [get_sprite player] returns the sprite of the player [player]. *)

val eat_fruit : t -> Fruit.t -> unit

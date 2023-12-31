(** This module defines types and functions for handling fruit entities in a game. *)

type fruit_type = Common.fruit_type
(** The [fruit_type] type represents the different types of fruits. *)

type direction = Common.direction
(** The [direction] type represents the direction in which the fruit can move. *)

(** The [fruit_state] type represents the current state of a fruit. *)
type fruit_state =
  | Eaten  (** Indicates the fruit has been eaten. *)
  | Left  (** Indicates the fruit is left or uneaten. *)
  | Bullet  (** Indicates the fruit is shot as bullet **)

type fruit = {
  mutable position : float * float;  (** The position of the fruit. *)
  speed : float;  (** The speed of the fruit **)
  mutable move_direction : direction;  (** The move direction of fruit **)
  mutable sprite : int * int;  (** Sprite position for the fruit. *)
  mutable fruit_type : fruit_type;  (** The type of the fruit. *)
  mutable fruit_state : fruit_state;  (** The current state of the fruit. *)
  mutable hit_counter : int;  (** How many times fruit hit the wall **)
}
(** The [fruit] type represents a fruit with various attributes. *)

type t = fruit
(** The type [t] is an alias for the [fruit] type. *)

val create : float * float -> fruit_type -> t
(** [create pos ftype] creates a new fruit of type [ftype] at position [pos]. *)

val update : t -> t
(** [update t] updates the fruit [t]. *)

val get_sprite : t -> int * int
(** [get_sprite t] returns the sprite of the fruit [t]. *)

val get_sprite_from_type : fruit_type -> int * int

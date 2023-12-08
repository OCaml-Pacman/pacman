(** This module defines types and functions for handling fruit entities in a game. *)

(** The [fruit_type] type represents the different types of fruits. *)
type fruit_type = 
  | Cherry       (** Represents a Cherry fruit. *)
  | Strawberry   (** Represents a Strawberry fruit. *)
  | Orange       (** Represents an Orange fruit. *)

(** The [fruit_state] type represents the current state of a fruit. *)
type fruit_state = 
  | Eaten        (** Indicates the fruit has been eaten. *)
  | Left         (** Indicates the fruit is left or uneaten. *)

(** The [fruit] type represents a fruit with various attributes. *)
type fruit = {
  mutable position : (float * float);       (** The position of the fruit. *)
  mutable sprite : (int * int);             (** Sprite position for the fruit. *)
  mutable fruit_type: fruit_type;           (** The type of the fruit. *)
  mutable fruit_state: fruit_state          (** The current state of the fruit. *)
}

(** The type [t] is an alias for the [fruit] type. *)
type t = fruit

(** [create pos ftype] creates a new fruit of type [ftype] at position [pos]. *)
val create : (float * float) -> fruit_type -> t

(** [update t] updates the fruit [t]. *)
val update : t -> t

(** [get_sprite t] returns the sprite of the fruit [t]. *)
val get_sprite: t -> (int * int)

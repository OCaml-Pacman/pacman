(** This module defines types and functions for managing the player and items in a game environment. *)

(** The [item] type represents the different types of items or entities in the game environment. *)
type item =
  | Wall      (** Represents a Wall. *)
  | Ground    (** Represents Ground. *)
  | Enemy     (** Represents an Enemy. *)
  | Orb       (** Represents an Orb. *)
  | BigOrb    (** Represents a Big Orb. *)
  | Player    (** Represents the Player. *)
  | Fruit of Fruit.fruit_type    (** Represents a Fruit. *)

(** The type [t] represents the game map or environment. *)
type t

(** [load filename] loads the map from the data file specified by [filename]. 
    Returns [true] if successful, otherwise [false]. *)
val load : string -> bool

(** [load_from_data data] loads the map from the given [data], typically used in tests. *)
val load_from_data : item array array ref -> unit

(** [reload ()] reloads the current map. *)
val reload : unit -> unit

(** [get_size ()] returns the size of the map as a float pair. *)
val get_size : unit -> (float * float)

(** [get_location pos] returns the item at the given coordinates [pos]. *)
val get_location : (float * float) -> item

(** [change_location pos item] updates the map with [item] at the given coordinates [pos]. *)
val change_location : (float * float) -> item -> unit

(** [get_item_count item] returns the number of [item] in the map. *)
val get_item_count: item -> int

(** [find_player ()] returns the coordinates of the player if present, otherwise [None]. *)
val find_player : unit -> (float * float) option

(** [find_enemies ()] returns a list of coordinates of all enemies in the map. *)
val find_enemies : unit -> (float * float) list

(** [find_fruits ()] returns a list of coordinates of all fruits in the map. *)
val find_fruits : unit -> ((float * float) * Fruit.fruit_type) list

(** [find_random_empty ()] returns the coordinates of a random empty space, if available, otherwise [None]. *)
val find_random_empty : unit -> (float * float) option

(** [remove_player ()] removes the player from the map. *)
val remove_player : unit -> unit

(** [remove_enemies ()] removes all enemies from the map. *)
val remove_enemies : unit -> unit

(** [remove_fruits ()] removes all fruits from the map. *)
val remove_fruits : unit -> unit

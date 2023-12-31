(** The [fruit_type] type represents the type of fruit. *)
type fruit_type =
  | Cherry  (** Represents a Cherry fruit. *)
  | Strawberry  (** Represents a Strawberry fruit. *)
  | Orange  (** Represents an Orange fruit. *)
[@@deriving equal]

(** The [direction] type represents the direction can move. *)
type direction =
  | Up  (** Represents moving up. *)
  | Down  (** Represents moving down. *)
  | Left  (** Represents moving left. *)
  | Right  (** Represents moving right. *)
[@@deriving equal]

(** The [enemy_type] type represents the different types of enemies. *)
type enemy_type =
  | Red  (** Represents a Red enemy. *)
  | Blue  (** Represents a Blue enemy. *)
  | Orange  (** Represents an Orange enemy. *)
  | Pink  (** Represents a Pink enemy. *)
[@@deriving equal]

(** Three function that return the direction after turn **)
val turn_left : direction -> direction
val turn_right : direction -> direction
val turn_back : direction -> direction

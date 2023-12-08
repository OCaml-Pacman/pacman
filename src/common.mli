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

[@@@coverage off]

type enemy_type = Red | Blue | Orange | Pink [@@deriving equal]
type fruit_type = Cherry | Strawberry | Orange [@@deriving equal]
type direction = Up | Down | Left | Right [@@deriving equal]

let turn_left direction =
  match direction with Up -> Left | Left -> Down | Down -> Right | Right -> Up

let turn_right direction =
  match direction with Up -> Right | Left -> Up | Down -> Left | Right -> Down

let turn_back direction =
  match direction with Up -> Down | Left -> Right | Down -> Up | Right -> Left

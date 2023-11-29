open Enemy
open Fruit
open Player

type state =  Active | Win | Lose 

type t = {
  player: Player.t;
  fruits: Fruit.t list;
  enemys: Enemy.t list;
  score: int;
  state: state;
}

let init_game_state (player:Player.t) (fruits:Fruit.t) (enemys:Enemy.t)  = 
  {
    player = player;
    fruits = fruits;
    enemys = enemys;
    score = 0;
    state = Active;
  }
(** [check_key key_char] checks if the given char [key_char] is a valid 
    movement. *)
let check_key (key_char: char) : bool = 
  match key_char with 
  | 'a' | 'w' | 's' | 'd' -> true 
  | _ -> false

(* let update_active  *)

(* let update (input_key : char option) (current_state : t) : t =
  match current_state.state with 
  | Active ->
  | Paused ->  *)

  (* let new_player = update_pacman input_key current_state.player in
  let new_enemys = update_ghosts current_state.enemys in
  let new_fruits = update_fruits current_state.fruits in
  let new_score = calculate_score current_state.score new_player new_fruits in
  { player = new_player; enemys = new_enemys; fruits = new_fruits; score = new_score } *)

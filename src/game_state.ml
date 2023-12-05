open Enemy
open Fruit
open Player

type state =  Active | Win | Lose 

type t = {
  player: Player.t;
  fruits: Fruit.t list;
  enemys: enemy list;
  score: int;
  state: state;
  game_counter: int
}

let init_game_state (player:Player.t) (fruits:Fruit.t list) (enemys:enemy list)  = 
  {
    player = player;
    fruits = fruits;
    enemys = enemys;
    score = 0;
    state = Active;
    game_counter = 0;
  }

(* the inital coordinates to put the game objects *)
let init_pos_player = (0.0, 0.0)
let init_pos_fruits = (20, 20)
let init_pos_enemy = (50, 50)

(** [check_key key_char] checks if the given char [key_char] is a valid 
    movement. *)
let check_key (key_char: char) : bool = 
  match key_char with 
  | 'a' | 'w' | 's' | 'd' -> true 
  | _ -> false


(**[check_overlap user_pos ghost] will return true if the distance between the 
   player position [user_pos] and the center of the ghost [ghost] are less 
   than a predetermined threshold amount, and false otherwise. *) 
let check_overlap (player:Player.t) (ghost:Ghost.t) : bool =
  let ghost_pos = Enemy.get_pos ghost in
  let ghost_x = fst ghost_pos in 
  let ghost_y = snd ghost_pos in 
  let player_pos = Enemy.get_pos player in
  let user_x = fst player_pos in 
  let user_y = snd player_pos in 
  let check_distance = 1 in 
  (Int.abs (ghost_x - user_x) <= check_distance && user_y = ghost_y) || 
  (Int.abs (ghost_y - user_y) <= check_distance && user_x = ghost_x)

(* get the scores when the ghost is eaten *) 
let get_ghost_score (ghosts_eaten: enemy_type) : int = 
  match ghosts_eaten with 
  | Red -> 200 
  | Blue -> 400 
  | Orange -> 800 
  | Pink -> 1600

let get_enemy_update (enemy:enemy) (player_pos:float * float) : enemy = 
  match enemy.enemy_type with
  | Red -> Red_enemy.update enemy player_pos
  | Blue -> Blue_enemy.update enemy player_pos
  | Orange -> Orange_enemy.update enemy player_pos
  | Pink -> Pink_enemy.update enemy player_pos
let new_game = 
  let new_player = Player.create init_pos_player in
  let new_red_enemy = Red_enemy.create init_pos_enemy in 
  let new_fruits = Fruit.create init_pos_fruits in 
  init_game_state new_player [new_fruits;new_fruits] [new_red_enemy; new_red_enemy]
  
  
let update_active cur_state = 
  let cur_player = cur_state.player in 
  let cur_enemys = cur_state.enemys in 
  let updated_enemy = 
     List.map cur_enemys ~f:(fun x -> get_enemy_update x cur_player.position) in
  let next_enemys = Enemy.update cur_state.enemys cur_state.player.position in
  let next_fruits = update_fruits current_state.fruits in
  let next_score = calculate_score current_state.score new_player new_fruits in
  { player = new_player; enemys = new_enemys; fruits = new_fruits; score = new_score }


(* let update (input_key : char option) (current_state : t) : t =
  match current_state.state with 
  | Active ->
  | Paused ->  *)

  
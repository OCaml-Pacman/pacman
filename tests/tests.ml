open Core
open OUnit2
open Enemy
open Player
open Game_state

(* Player Test *)

let test_map_data = ref [| [| Game_map.Ground; Game_map.Ground |] |]
let test_update_player _ =
  (* assert_equal true @@ (Game_map.load "map.csv"); *)
  Game_map.load_from_data test_map_data;
  let player = Player.create (0.0, 0.0) in
  assert_equal player.move_counter @@ 0;
  let player = Player.update player None in
  assert_equal player.move_counter @@ 1
  (* assert_equal player.position @@ (1.0, 0.0);
  let player = Player.update player None in
  assert_equal player.move_counter @@ 2;
  assert_equal player.position @@ (0.0, 0.0);
  let player = Player.update player (Key 'w') in
  assert_equal player.move_counter @@ 3;
  assert_equal player.position @@ (0.0, 0.0);
  let player = Player.update player (Key 'a') in
  assert_equal player.move_counter @@ 0;
  assert_equal player.position @@ (1.0, 0.0) *)

let player_tests =
  "Player Tests" >: test_list [ "test update player" >:: test_update_player ]

(* Enemy Test *)
let test_update_enemy _ =
  let test_map_data = ref [| 
  [| Game_map.Wall; Game_map.Wall; Game_map.Wall; |] ;  
  [|Game_map.Wall; Game_map.Ground; Game_map.Ground; |];
  [| Game_map.Wall; Game_map.Wall; Game_map.Wall; |] |] in
  Game_map.load_from_data test_map_data;
  let test_enemy1 = Red_enemy.create (1.0, 1.0) in
  assert_equal 0 @@ test_enemy1.move_counter;
  assert_equal (1.0, 1.0) @@ Red_enemy.get_pos test_enemy1;
  let updated_enemy = Red_enemy.update test_enemy1 (0.0, 0.0) in
  assert_equal 1 @@ updated_enemy.move_counter;
  let enemy_speed = 0.04 in  
  assert_equal true @@ (Float.(=) (1.0 +. enemy_speed) (fst updated_enemy.position));

  let test_enemy2 = Red_enemy.create (1.0, 1.0) in
  test_enemy2.enemy_state <- Scared;
  let updated_enemy2 = Red_enemy.update test_enemy2 (0.0, 0.0) in
  assert_equal 1 @@ updated_enemy2.move_counter;
  let scared_speed = 0.02 in  
  assert_equal true @@ (Float.(=) (1.0 +. scared_speed) (fst updated_enemy2.position));

  let test_enemy3 = Red_enemy.create (1.0, 1.0) in
  test_enemy3.enemy_state <- Dead;
  let updated_enemy3 = Red_enemy.update test_enemy3 (0.0, 0.0) in
  assert_equal true @@ (Float.(=) 1.0 (fst updated_enemy3.position));

  let test_enemy4 = Red_enemy.create (1.0, 1.0) in
  test_enemy4.move_direction <- 2;
  let updated_enemy4 = Red_enemy.update test_enemy4 (0.0, 0.0) in
  assert_equal 0 @@ updated_enemy4.move_direction


let enemy_tests =
  "Enemy Tests" >: test_list [ "test enemy" >:: test_update_enemy ]

let test_game_state _ = 
  let test_map_data = ref [| 
    [| Game_map.Wall; Game_map.Wall; Game_map.Wall; Game_map.Wall;|] ;  
    [|Game_map.Wall; Game_map.Player; Game_map.Orb; Game_map.Wall; |];
    [|Game_map.Wall; Game_map.BigOrb; Game_map.Ground; Game_map.Wall; |];
    [| Game_map.Wall; Game_map.Wall; Game_map.Wall; Game_map.Wall;|] |] in
    Game_map.load_from_data test_map_data;
  let test_game = Game_state.new_game () in
  assert_equal 0 @@ test_game.score;
  let player = test_game.player in
  player.position <- (1.0, 2.0);
  let updated_game = Game_state.update (Some 's') test_game in
  assert_equal true @@ updated_game.enemy_scared;
  let updated_game = Game_state.update (Some 's') test_game in
  assert_equal 1 @@ updated_game.enemy_scared_timer;
  let test_game = Game_state.new_game () in
  let player = test_game.player in
  player.position <- (2.0, 1.0);
  let updated_game = Game_state.update (Some 'd') test_game in
  assert_equal 1 @@ updated_game.score;
  let updated_game = Game_state.update (Some 'd') test_game in
  assert_equal 0 @@ updated_game.score

let test_game_state2 _ = 
  let test_map_data = ref [| 
    [| Game_map.Wall; Game_map.Wall; Game_map.Wall; Game_map.Wall;|] ;  
    [|Game_map.Wall; Game_map.Player; Game_map.Enemy; Game_map.Wall; |];
    [|Game_map.Wall; Game_map.Enemy; Game_map.Enemy; Game_map.Wall; |];
    [| Game_map.Wall; Game_map.Wall; Game_map.Wall; Game_map.Wall;|] |] in
    Game_map.load_from_data test_map_data;
  let test_game = Game_state.new_game () in
  let updated_game = Game_state.update (Some 'w') test_game in
  let helper = match get_state updated_game with
  | Game_state.Lose -> 0
  | Game_state.Active -> 1
  | Game_state.Win -> 2
  in
  assert_equal 1 @@ helper

 

let game_state_tests =
  "Game State Tests" >: test_list [ 
    "test game state" >:: test_game_state;
    "test game state2" >:: test_game_state2
     ]



let series = "Pacman Tests" >::: [ player_tests; enemy_tests; game_state_tests ]
let () = run_test_tt_main series

open Core
open OUnit2
open Enemy
open Player

(* Player Test *)

let test_map_data = ref [| [| Game_map.Ground; Game_map.Ground |] |]
let test_update_player _ =
  (* assert_equal true @@ (Game_map.load "map.csv"); *)
  Game_map.load_from_data test_map_data;
  let player = Player.create (0.0, 0.0) in
  assert_equal player.move_counter @@ 0;
  let player = Player.update player None in
  assert_equal player.move_counter @@ 1;
  assert_equal player.position @@ (1.0, 0.0);
  let player = Player.update player None in
  assert_equal player.move_counter @@ 2;
  assert_equal player.position @@ (0.0, 0.0);
  let player = Player.update player (Key 'w') in
  assert_equal player.move_counter @@ 3;
  assert_equal player.position @@ (0.0, 0.0);
  let player = Player.update player (Key 'a') in
  assert_equal player.move_counter @@ 0;
  assert_equal player.position @@ (1.0, 0.0)

let player_tests =
  "Player Tests" >: test_list [ "test update player" >:: test_update_player ]

(* Enemy Test *)
(* let test_match_dir_to_ind () =
   assert (match_dir_to_ind 0 = (1.0, 0.0));
   assert (match_dir_to_ind 1 = (-1.0, 0.0));
   assert (match_dir_to_ind 2 = (0.0, 1.0));
   assert (match_dir_to_ind 3 = (0.0, -1.0));
   try
     let _ = match_dir_to_ind 5 in
     assert false
   with
   | Failure "invalid int of direction" -> ()
   | _ -> assert false *)

let test_update_enemy _ =
  let test_map_data = ref [| [| Game_map.Ground; Game_map.Ground; Game_map.Ground; Game_map.Ground |];
  [| Game_map.Ground; Game_map.Ground; Game_map.Ground; Game_map.Ground |] |]in 
  Game_map.load_from_data test_map_data;
  let test_enemy1 = Red_enemy.create (0.0, 0.0) in
  assert_equal 0 @@ test_enemy1.move_counter
  (* let updated_enemy = Red_enemy.update test_enemy1 (3.0, 0.0) in
  assert_equal 1 @@ updated_enemy.move_counter *)



(* let test_new_game = new_game
   let test_game_win _ =
     test_new_game.state <- Win;
     let test_game_next = update (Some 'w') test_new_game in
     assert_equal 0 @@ test_game_next.score *)
let enemy_tests =
  "Enemy Tests" >: test_list [ "test enemy" >:: test_update_enemy ]

let series = "Pacman Tests" >::: [ player_tests; enemy_tests ]
let () = run_test_tt_main series

open Core
open OUnit2
open Enemy

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
  let test_enemy1 = Red_enemy.create (5.0, 5.0) in
  let updated_enemy = Red_enemy.update test_enemy1 (10.0, 10.0) in
  assert_equal 1 @@ updated_enemy.move_counter

(* let test_new_game = new_game
let test_game_win _ = 
  test_new_game.state <- Win;
  let test_game_next = update (Some 'w') test_new_game in
  assert_equal 0 @@ test_game_next.score *)
let tests =
  "Pacman Tests"
  >: test_list
       [
         "test distribution" >:: test_update_enemy;
       ]

let series = "Pacman Tests" >::: [ tests ]
let () = run_test_tt_main series
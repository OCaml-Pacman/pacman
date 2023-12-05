open Base
open Core
open OUnit2
open Enemy

(* Enemy Test *)
let test_match_dir_to_ind () =
  assert (match_dir_to_ind 0 = (1.0, 0.0));
  assert (match_dir_to_ind 1 = (-1.0, 0.0));
  assert (match_dir_to_ind 2 = (0.0, 1.0));
  assert (match_dir_to_ind 3 = (0.0, -1.0));
  try
    let _ = match_dir_to_ind 5 in
    assert false
  with
  | Failure "invalid int of direction" -> ()
  | _ -> assert false

let test_update_red_enemy () =
  let enemy = Red_enemy.create (5.0, 5.0) in
  let updated_enemy = Red_enemy.update enemy (10.0, 10.0) in
  (* Assertions to check if the enemy's position and move_direction are updated correctly *)
  

let tests =
  "Pacman Tests"
  >: test_list
       [
         "test distribution" >:: test_distribution;
       ]

let series = "Pacman Tests" >::: [ tests ]
let () = run_test_tt_main series
open Core
open OUnit2
open Enemy
open Player
open Game_state
open Game_map

(* Player Test *)

let rec player_no_input_update (player : Player.t) (n : int) : unit =
  if n > 0 then (
    Player.update player None;
    player_no_input_update player (n - 1))

let test_map_data = ref [| [| Ground; Ground |] |]
(* let print_float_pair (x, y) = Printf.printf "(%f, %f)\n" x y *)

let test_update_player _ =
  load_from_data test_map_data;
  let player = Player.create (0.0, 0.0) ~speed:1.0 in
  assert_equal player.move_counter @@ 0;
  player_no_input_update player 1;
  assert_equal player.move_counter @@ 1;
  assert_equal player.position @@ (1.0, 0.0);
  player_no_input_update player 1;
  assert_equal player.move_counter @@ 2;
  assert_equal player.position @@ (0.0, 0.0);
  Player.update player (Key 'w');
  assert_equal player.move_counter @@ 3;
  assert_equal player.position @@ (0.0, 0.0);
  player_no_input_update player 4;
  Player.update player (Key 'a');
  assert_equal (get_sprite player) @@ (2, 0);
  assert_equal player.position @@ (1.0, 0.0);
  player_no_input_update player 3;
  assert_equal player.move_counter @@ 3;
  assert_equal player.position @@ (0.0, 0.0)

let test_map_data =
  ref
    [|
      [| Wall; Wall; Wall; Wall |];
      [| Wall; Ground; Ground; Wall |];
      [| Wall; Wall; Wall; Wall |];
    |]

let test_move_player _ =
  load_from_data test_map_data;
  let player = Player.create (1.0, 1.0) ~speed:0.4 in
  Player.update player (Key 's');
  assert_equal player.position @@ (1.0, 1.0);
  player_no_input_update player 3;
  assert_equal player.position @@ (1.0, 1.0);
  Player.update player (Key 'd');
  assert_equal player.position @@ (1.4, 1.0);
  player_no_input_update player 3;
  assert_equal player.position @@ (2.0, 1.0)

let test_map_data =
  ref
    [|
      [| Wall; Wall; Wall; Wall |];
      [| Wall; Ground; Ground; Wall |];
      [| Wall; Wall; Wall; Wall |];
    |]

let test_player_interact_fruit _ =
  load_from_data test_map_data;
  let player = Player.create (1.0, 1.0) ~speed:0.0 in
  let cherry = Fruit.create (1.0, 1.0) Common.Cherry in
  let starwberry = Fruit.create (2.0, 1.0) Common.Strawberry in
  Player.update player (Key 'd');
  assert_equal player.position @@ (1.0, 1.0);
  assert_equal player.player_state @@ Alive;
  eat_fruit player cherry;
  assert_equal player.player_state @@ Armed;
  assert_equal (List.length player.fruits) @@ 1;
  eat_fruit player starwberry;
  assert_equal (List.length player.fruits) @@ 2;
  Player.update player (Key 'j');
  assert_equal (List.length player.fruits) @@ 1;
  Player.update player (Key 'w');
  Player.update player (Key 'j');
  assert_equal (List.length player.fruits) @@ 1;
  Player.update player (Key 's');
  Player.update player (Key 'j');
  assert_equal (List.length player.fruits) @@ 1;
  Player.update player (Key 'd');
  Player.update player (Key 'j');
  assert_equal player.player_state @@ Alive;
  assert_equal (List.length player.fruits) @@ 0

let player_tests =
  "Player Tests"
  >: test_list
       [
         "test update player" >:: test_update_player;
         "test move player" >:: test_move_player;
         "test player interact fruit" >:: test_player_interact_fruit;
       ]

(* Enemy Test *)
let test_update_enemy_red _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall |];
        [| Wall; Ground; Ground |];
        [| Wall; Wall; Wall |];
      |]
  in
  load_from_data test_map_data;
  let test_enemy1 = Red_enemy.create (1.0, 1.0) in
  assert_equal 0 @@ test_enemy1.move_counter;
  assert_equal (1.0, 1.0) @@ Red_enemy.get_pos test_enemy1;
  let updated_enemy = Red_enemy.update test_enemy1 (0.0, 0.0) in
  assert_equal 1 @@ updated_enemy.move_counter;
  let enemy_speed = 0.04 in
  assert_equal true
  @@ Float.( = ) (1.0 +. enemy_speed) (fst updated_enemy.position);

  assert_equal (0, 4) @@ get_enemy_sprite_by_type Red;
  assert_equal (0, 5) @@ get_enemy_sprite_by_type Pink;
  assert_equal (0, 6) @@ get_enemy_sprite_by_type Blue;
  assert_equal (0, 7) @@ get_enemy_sprite_by_type Orange;

  updated_enemy.move_direction <- 5;
  assert_raises (InvalidDirection 5) (fun () -> Red_enemy.update test_enemy1 (0.0, 0.0));


  let test_enemy2 = Red_enemy.create (1.0, 1.0) in
  test_enemy2.enemy_state <- Scared;
  let updated_enemy2 = Red_enemy.update test_enemy2 (0.0, 0.0) in
  assert_equal 1 @@ updated_enemy2.move_counter;
  let scared_speed = 0.02 in
  assert_equal true
  @@ Float.( = ) (1.0 +. scared_speed) (fst updated_enemy2.position);

  let test_enemy3 = Red_enemy.create (1.0, 1.0) in
  test_enemy3.enemy_state <- Dead;
  let updated_enemy3 = Red_enemy.update test_enemy3 (0.0, 0.0) in
  assert_equal true @@ Float.( = ) 1.0 (fst updated_enemy3.position);


  let test_enemy4 = Red_enemy.create (1.0, 1.0) in
  test_enemy4.move_direction <- 1;
  test_enemy4.speed <- 0.5;
  let updated_enemy4 = Red_enemy.update test_enemy4 (0.0, 0.0) in
  assert_equal 0 @@ updated_enemy4.move_direction;
  updated_enemy.dead_timer <- 401;
  assert_equal 0 @@ updated_enemy4.dead_timer
  

let test_update_enemy_pink _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall |];
        [| Wall; Ground; Ground; Wall |];
        [| Wall; Player; Ground; Wall |];
        [| Wall; Wall; Wall; Wall |];
      |]
  in
  load_from_data test_map_data;
  let test_enemy1 = Pink_enemy.create (1.0, 1.0) in
  let updated_enemy = ref (Pink_enemy.update test_enemy1 (1.0, 2.0)) in
  for _ = 1 to 48 do
    updated_enemy := Pink_enemy.update !updated_enemy (1.0, 2.0)
  done;
  (!updated_enemy).position <- (1.0, 1.0);
  (!updated_enemy).move_direction <- 0;
  updated_enemy := Pink_enemy.update !updated_enemy (1.0, 2.0);
  assert_equal 2 @@ (!updated_enemy).move_direction

let test_update_enemy_blue _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall;Wall |];
        [| Wall; Ground; Ground; Ground;Wall |];
        [| Wall; Ground; Ground; Ground;Wall |];
        [| Wall; Ground; Wall; Wall;Wall |];
        [| Wall; Ground; Ground; Player;Wall |];
        [| Wall; Wall; Wall; Wall;Wall |];
      |]
  in
  load_from_data test_map_data;
  let test_enemy1 = Blue_enemy.create (1.0, 1.0) in
  let updated_enemy = Blue_enemy.update test_enemy1 (3.0, 4.0) in
  assert_equal 2 @@ updated_enemy.move_direction

let test_update_enemy_orange _ =
  let test_enemy1 = Orange_enemy.create (1.0, 1.0) in
  let updated_enemy = ref (Orange_enemy.update test_enemy1 (1.0, 2.0)) in
  for _ = 1 to 51 do
    updated_enemy := Orange_enemy.update !updated_enemy (1.0, 2.0)
  done;
  assert_equal true @@ Float.(=.) 0.042 !updated_enemy.speed;
  for _ = 1 to 2000 do
    updated_enemy := Orange_enemy.update !updated_enemy (1.0, 2.0)
  done;
  assert_equal true @@ Float.(=.) 0.086 !updated_enemy.speed


let enemy_tests =
  "Enemy Tests" >: test_list [ 
    "test enemy red" >:: test_update_enemy_red;
  "test enemy pink" >:: test_update_enemy_pink;
  "test enemy blue" >:: test_update_enemy_blue;
  "test enemy orange" >:: test_update_enemy_orange;

   ]

let create_file_with_content filename content =
  Out_channel.with_file filename ~f:(fun oc ->
      Out_channel.output_string oc content)

let test_load_map_from_file _ =
  create_file_with_content "test_map.csv"
    "#,#,#,#,#\n#,.,C,F,#\n#,G,H,*,#\n#,R,B,P,#\n#,O,.,.,#\n#,#,#,#,#";
  assert_equal (load "test_map.csv") @@ true;
  let game = Game_state.new_game () in
  assert_equal game.player.position @@ (2.0, 1.0);
  assert_equal (List.length (get_enemies game)) @@ 4;
  assert_equal (List.length (get_fruits game)) @@ 3;
  create_file_with_content "test_map.csv" "#,#,A,#,#";
  assert_equal (load "test_map.csv") @@ false

let map_tests =
  "Map Tests"
  >: test_list [ "test load map from file" >:: test_load_map_from_file ]

let test_basic_move _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall |];
        [| Wall; Player; Orb; Wall |];
        [| Wall; BigOrb; Ground; Wall |];
        [| Wall; Wall; Wall; Wall |];
      |]
  in
  load_from_data test_map_data;
  let game = Game_state.new_game () in
  assert_equal 0 @@ game.score;
  let player = get_player game in
  player.position <- (1.0, 2.0);
  let updated_game = Game_state.update (Some 's') game in
  assert_equal true @@ updated_game.enemy_scared;
  let updated_game = Game_state.update (Some 's') game in
  assert_equal 1 @@ updated_game.enemy_scared_timer;
  let game = Game_state.new_game () in
  let player = game.player in
  player.position <- (2.0, 1.0);
  let updated_game = Game_state.update (Some 'd') game in
  assert_equal 1 @@ updated_game.score;
  let updated_game = Game_state.update (Some 'd') game in
  assert_equal 0 @@ updated_game.score;
  let helper =
    match get_state game with
    | Game_state.Lose -> 0
    | Game_state.Active -> 1
    | Game_state.Win -> 2
  in
  assert_equal 2 @@ helper

let rec wait_for_frame (game_state : Game_state.t) (n : int) : Game_state.t =
  if n > 0 then wait_for_frame (Game_state.update None game_state) (n - 1)
  else game_state

let test_shot_fruit_to_enemy _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall; Wall; Wall |];
        [| Wall; Player; Fruit Orange; Orb; Enemy Red; Wall |];
        [| Wall; Wall; Wall; Wall; Wall; Wall |];
      |]
  in
  load_from_data test_map_data;
  let game = Game_state.new_game () in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.enemys) @@ 1;
  assert_equal (List.length game.fruits) @@ 1;
  let game = wait_for_frame game 2 in
  assert_equal game.player.player_state @@ Armed;
  assert_equal (List.length game.fruits) @@ 0;
  let game = Game_state.update (Some 'j') game in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = wait_for_frame game 10 in
  assert_equal (List.length game.fruits) @@ 0

let test_shot_cherry_to_wall _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall; Wall |];
        [| Wall; Orb; Fruit Cherry; Player; Wall |];
        [| Wall; Wall; Wall; Wall; Wall |];
      |]
  in
  load_from_data test_map_data;
  let game = Game_state.new_game () in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = Game_state.update (Some 'a') game in
  assert_equal game.player.player_state @@ Armed;
  assert_equal (List.length game.fruits) @@ 0;
  let game = Game_state.update (Some 'j') game in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = wait_for_frame game 10 in
  assert_equal (List.length game.fruits) @@ 0


let test_shot_strawberry_to_wall _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall |];
        [| Wall; Orb; Wall |];
        [| Wall; Fruit Strawberry; Wall |];
        [| Wall; Player; Wall |];
        [| Wall; Wall; Wall; Orb |];
      |]
  in
  load_from_data test_map_data;
  let game = Game_state.new_game () in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = Game_state.update (Some 'w') game in
  assert_equal game.player.player_state @@ Armed;
  assert_equal (List.length game.fruits) @@ 0;
  let game = Game_state.update (Some 'j') game in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = wait_for_frame game 3 in
  assert_equal (List.length game.fruits) @@ 1;
  assert_equal (List.last_exn game.fruits).move_direction @@ Up;
  let game = wait_for_frame game 3 in
  assert_equal (List.length game.fruits) @@ 1;
  assert_equal (List.last_exn game.fruits).move_direction @@ Down;
  let game = wait_for_frame game 40 in
  assert_equal (List.length game.fruits) @@ 0

let test_shot_orange_to_wall _ =
  let test_map_data =
    ref
      [|
        [| Wall; Wall; Wall; Wall; Wall |];
        [| Wall; Wall; Wall; Orb; Wall |];
        [| Wall; Player; Fruit Orange; Orb; Wall |];
        [| Wall; Wall; Wall; Orb; Wall |];
        [| Wall; Wall; Wall; Wall; Orb |];
      |]
  in
  load_from_data test_map_data;
  let game = Game_state.new_game () in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = Game_state.update (Some 'd') game in
  assert_equal game.player.player_state @@ Armed;
  assert_equal (List.length game.fruits) @@ 0;
  let game = Game_state.update (Some 'j') game in
  assert_equal game.player.player_state @@ Alive;
  assert_equal (List.length game.fruits) @@ 1;
  let game = wait_for_frame game 3 in
  assert_equal (List.length game.fruits) @@ 1;
  assert_equal (List.last_exn game.fruits).move_direction @@ Right;
  let game = wait_for_frame game 3 in
  assert_equal (List.length game.fruits) @@ 1;
  assert_equal (List.last_exn game.fruits).move_direction @@ Down;
  let game = wait_for_frame game 10 in
  assert_equal (List.length game.fruits) @@ 1;
  assert_equal (List.last_exn game.fruits).move_direction @@ Up;
  let game = wait_for_frame game 20 in
  assert_equal (List.length game.fruits) @@ 0

let game_state_tests =
  "Game State Tests"
  >: test_list
       [
         "test basic move" >:: test_basic_move;
         "test shot fruit to enemy" >:: test_shot_fruit_to_enemy;
         "test shot cherry to wall" >:: test_shot_cherry_to_wall;
         "test shot strawberry to wall" >:: test_shot_strawberry_to_wall;
         "test shot orange to wall" >:: test_shot_orange_to_wall;
       ]

let series =
  "Pacman Tests" >::: [ 
    player_tests; 
    enemy_tests; 
    map_tests; 
    game_state_tests
     ]

let () = run_test_tt_main series

open Core
open Common

type enemy_type = Common.enemy_type
type enemy_state = Active | Scared | Dead

type enemy = {
    mutable position : float * float;
    mutable enemy_state : enemy_state;
    mutable enemy_type: enemy_type;
    mutable move_counter : int;
    mutable move_direction : int;
    mutable sprite : int * int; 
    init_pos : float * float;
}

type direction = Up | Down | Left | Right [@@deriving equal, compare, sexp]

let match_dir_to_ind dir = 
  match dir with
  | 0 -> (1.0, 0.0)
  | 1 -> (-1.0, 0.0)
  | 2 -> (0.0, 1.0)
  | 3 -> (0.0, -1.0)
  | _ -> failwith "invalid int of direction"

let helper_dir int_direction = 
  match int_direction with
  | 0 -> Right
  | 1 -> Left
  | 2 -> Down
  | 3 -> Up
  | _ -> failwith "invalid int of direction"

let match_dir_to_int direction = 
  match direction with
  | Right -> 0
  | Left -> 1
  | Down -> 2
  | Up -> 3

let get_enemy_sprite_by_type enemy = 
  match enemy with
  | Pink -> (0,5)
  | Red -> (0,4)
  | Blue ->(0,6)
  | Orange -> (0,7)
  
let check_collsion int_direction pos = 
  let direction = helper_dir int_direction in 
  let (x,y) = pos in
  let (jx, jy) = (Float.add x 0.05, Float.add y 0.05) in
  let roundXPos = (Float.round x, y) in
  let roundYPos = (x, Float.round y) in
  let roundPos = (Float.round x, Float.round y) in
  let ul = Game_map.get_location (jx, jy) in
  let ur = Game_map.get_location (Float.add jx 0.90,jy) in
  let dl = Game_map.get_location (jx,Float.add jy 0.90) in
  let dr = Game_map.get_location (Float.add jx 0.90, Float.add jy 0.90) in
  match direction, ul, ur, dl, dr with
    | Up, Wall, Wall, _, _ -> roundYPos
    | Up, Wall, _, _, _ -> roundPos
    | Up, _, Wall, _, _ -> roundPos
    | Down, _, Wall, Wall, _ -> roundYPos
    | Down, _, _, _, Wall -> roundPos
    | Down, _, _, Wall, _ -> roundPos
    | Left, Wall, _, Wall, _ -> roundXPos
    | Left, Wall, _, _, _ -> roundPos
    | Left, _, _, Wall, _ -> roundPos
    | Right, _, Wall, _, Wall -> roundXPos
    | Right, _, Wall, _, _ -> roundPos
    | Right, _, _, _, Wall -> roundPos
    | _ -> pos

let is_wall (pos : float * float) : bool =
  let pos2 = (fst pos +. 0.95, snd pos +. 0.95) in
  match (Game_map.get_location pos, Game_map.get_location pos2) with
  | Wall, _ -> true
  | _, Wall -> true
  | _ -> false

module type SetEnemyType = sig
  type t = enemy
  val move :  t -> (float * float) ->  t
  val get_enemytype : enemy_type
  val get_sprite : (int * int) list list
end

module type Enemy =
sig
  type t = enemy
  
  val get_pos : t -> (float * float)
  val create : (float * float) -> t
  val update : t -> (float * float) ->  t
end

module MakeEnemy (M : SetEnemyType) : Enemy = struct
  type t = enemy

  let get_sprite_by_dir d counter sprites = 
    match d with 
    | 0 -> List.nth_exn (List.nth_exn sprites 0) counter 
    | 1 -> List.nth_exn (List.nth_exn sprites 1) counter
    | 2 -> List.nth_exn (List.nth_exn sprites 2) counter
    | 3 -> List.nth_exn (List.nth_exn sprites 3) counter
    | _ -> failwith "invalid direction"
  
  let create (init_pos:(float * float)) : t =   
  {
    position = init_pos;
    enemy_state = Active;
    enemy_type = M.get_enemytype;
    move_counter = 0;
    move_direction = 0;
    sprite = get_sprite_by_dir 0 0 M.get_sprite;
    init_pos = init_pos;
  }
  
  let get_pos (e:t) : (float * float) = e.position  

  let scared_speed = 0.02
    
  let update (cur_e : t) (player_pos : (float * float))  : t = 
    let next_counter = cur_e.move_counter + 1 in
    cur_e.move_counter <- next_counter;
    (* check cur_enemy state *)
    match cur_e.enemy_state with
    | Active -> 
          (* call move function to update position and direction *)
          let moved_e = M.move cur_e player_pos in
          (* find the corrsponding sprite *)
          let animated_ind = next_counter mod 2 in 
          moved_e.sprite <- get_sprite_by_dir moved_e.move_direction animated_ind M.get_sprite;
          moved_e

    | Scared -> 
      (* scared enemy moved in the same direction as before with slower speed until hit the wall *)
      let rec aux d = 
        let dx, dy = match_dir_to_ind d in
        let next_x = (fst cur_e.position) +. (dx *. scared_speed) in
        let next_y = (snd cur_e.position) +. (dy *. scared_speed) in
        if is_wall (next_x, next_y) then aux ((d+1) mod 4)
        else 
          (cur_e.position <- check_collsion d (next_x, next_y);
          cur_e.move_direction <- d)            
      in aux cur_e.move_direction;
      (* find the corrsponding sprite *)
      let scared_coordinates = [(8, 4); (9, 4)] in
      let animated_ind = next_counter mod 2 in 
        cur_e.sprite <- List.nth_exn scared_coordinates animated_ind;
        cur_e
    
    | Dead -> 
        cur_e.position <- cur_e.init_pos;
        cur_e.sprite <- (10, 4);
        cur_e

end

module Set_red_enemy : SetEnemyType = struct
  type t = enemy
  (* Red enemy move randomly *)
  let get_enemytype = Red
  let get_sprite = [[(0, 4); (1, 4)]; [(2, 4); (3, 4)];  [(6, 4); (7, 4)]; [(4, 4); (5, 4)]]
  let enemy_speed = 0.04
  let change_counter = ref 1

  let move (cur_e : t) (player_pos : (float * float)) : t =  
    let rec aux () = 
      let selected_dir = (Random.self_init (); Random.int 4) in 
      let tempx, tempy = player_pos in
      let dx, dy = match_dir_to_ind selected_dir in
      let next_x = (fst cur_e.position) +. (dx *. enemy_speed) +. 0.0 *. tempx in
      let next_y = (snd cur_e.position) +. (dy *. enemy_speed) +. 0.0 *. tempy in             
        if is_wall (next_x, next_y) then aux ()
        else 
          (cur_e.position <- check_collsion selected_dir (next_x, next_y);
          cur_e.move_direction <- selected_dir;
          cur_e)
        in
    let d = cur_e.move_direction in
    let dx, dy = match_dir_to_ind d in
    let next_x = (fst cur_e.position) +. (dx *. enemy_speed) in
    let next_y = (snd cur_e.position) +. (dy *. enemy_speed) in
    if (!change_counter) mod 30 = 0 then 
      (change_counter := 1;
      aux ())
    else 
    (
      change_counter := !change_counter + 1;  
      (* match Game_map.get_location  (check_x, check_y) with *)
      if is_wall (next_x, next_y) then aux ()
      else 
        (cur_e.position <- check_collsion d (next_x, next_y);
        cur_e)
    )
end

module Set_pink_enemy : SetEnemyType = struct
  type t = enemy
  (* Pink enemy move to the direction closest to pacman (Manhattan distance) every 50 renders *)
  let get_enemytype = Pink
  let get_sprite = [[(0, 5); (1, 5)]; [(2, 5); (3, 5)]; [(6, 5); (7, 5)];[(4, 5); (5, 5)]; ]
  let enemy_speed = 0.04
  let change_counter = ref 1

  let get_distance (player_pos : float * float) (enemy_pos : float * float) : float =
    let ghost_x = fst enemy_pos in
    let ghost_y = snd enemy_pos in
    let user_x = fst player_pos in
    let user_y = snd player_pos in
    Float.abs (ghost_x -. user_x) +. Float.abs (ghost_y -. user_y)
  
  let change_direction (enemy_pos : float * float) (dir:direction) : (float * float) = 
    let dx, dy = dir |> match_dir_to_int |> match_dir_to_ind  in
    let next_x = (fst enemy_pos) +. dx in
    let next_y = (snd enemy_pos) +. dy in 
    (next_x, next_y)

  let get_best_dir (player_pos : float * float) (enemy_pos : float * float) : direction = 
    let dir_list = [Up;Down;Right;Left] in
    let all_dist = List.map dir_list ~f:(fun d -> (d, get_distance player_pos (change_direction enemy_pos d))) in
    let best_dir = List.fold all_dist ~init:(List.nth_exn all_dist 0) ~f:(fun acc -> fun x -> 
      if Float.(<=) (snd acc) (snd x) then acc else x) in 
      fst best_dir

  let move (cur_e : t) (player_pos : (float * float)) : t =  
    let rec aux is_random = 
      let selected_dir = 
        if is_random then (Random.self_init (); Random.int 4)
        else match_dir_to_int (get_best_dir player_pos cur_e.position) 
      in
      let dx, dy = match_dir_to_ind selected_dir in
      let next_x = (fst cur_e.position) +. (dx *. enemy_speed)  in
      let next_y = (snd cur_e.position) +. (dy *. enemy_speed)  in
      if is_wall (next_x, next_y) then aux true
      else     
         (cur_e.position <- check_collsion selected_dir (next_x, next_y);
         cur_e.move_direction <- selected_dir;
         cur_e)
       in 
       let d = cur_e.move_direction in
       let dx, dy = match_dir_to_ind d in
       let next_x = (fst cur_e.position) +. (dx *. enemy_speed) in
       let next_y = (snd cur_e.position) +. (dy *. enemy_speed) in
       if (!change_counter) mod 50 = 0 then 
         (change_counter := 1;
          aux false)
       else 
       (
         change_counter := !change_counter + 1;  
         if is_wall (next_x, next_y) then aux false
         else 
           (cur_e.position <- check_collsion d (next_x, next_y);
           cur_e)
       )
  
end

module BFS = struct

  type node = {
    position : float * float;
    parent : node option;
    direction_from_parent: direction;
  } [@@deriving equal, compare, sexp]

  let create_node position direction_from_parent parent = {
    position;
    direction_from_parent;
    parent;
  }

  module Position = struct
    type t = float * float [@@deriving equal, compare, sexp]
  end
  
  module PositionSet = Set.Make(Position)
      
  let check_position_equal player_pos enemy_pos =
    let ghost_x = fst enemy_pos in
      let ghost_y = snd enemy_pos in
      let user_x = fst player_pos in
      let user_y = snd player_pos in
      let check_distance = 0.5 in
      let dx = user_x -. ghost_x in
      let dy = user_y -. ghost_y in
      let dist = sqrt ((dx *. dx) +. (dy *. dy)) in
      Float.( <= ) dist check_distance

    let get_neighbors node =
      let x, y = node.position in
      [
        ((x +. 1.0, y), Right); 
        ((x -. 1.0, y), Left);
        ((x , y +. 1.0), Down);
        ((x , y -. 1.0), Up);]
      |> List.filter ~f: (fun pos -> 
        let x_max, y_max = Game_map.get_size () in
        if ((Float.between (fst (fst pos)) ~low:0.0  ~high: (x_max-.1.0))
          && (Float.between (snd (fst pos)) ~low:0.0  ~high: (y_max-.1.0)))
        then (if is_wall (fst pos) then false else true)
        else false)
        

    let bfs start_pos end_pos =
      let rec loop queue visited =
        if Deque.is_empty queue then None
        else 
          (
          let head = Deque.dequeue_front_exn queue in
          let pos = head.position in
          if check_position_equal pos end_pos then
            ( Some head ) (* Path found *)
          else if Set.mem visited pos then
            loop queue visited
          else
            let new_visited = Set.add visited pos in
            let neighbors = get_neighbors head in
            List.iter neighbors ~f:(fun ((nx, ny), dir) -> 
              let temp = create_node (nx, ny) dir (Some head) in
              Deque.enqueue_back queue temp; );
            loop queue new_visited)
      in
      let visited_set = PositionSet.empty in
      let node_queue = Deque.create () in
      Deque.enqueue_front node_queue (create_node start_pos Up None);
      loop node_queue visited_set

  let rec trace_back_for_direction node =
    match node.parent with
    | None -> node.direction_from_parent 
    | Some parent -> 
        match parent.parent with
        | None -> node.direction_from_parent
        | Some _ -> trace_back_for_direction parent

        let get_best_dir (player_pos : float * float) (enemy_pos : float * float) : direction = 
          let find_end = bfs (Float.round_nearest (fst enemy_pos), Float.round_nearest (snd enemy_pos)) 
          (Float.round_nearest (fst player_pos), Float.round_nearest (snd player_pos)) in
          match find_end with
          | Some e ->
            trace_back_for_direction e 
          | None -> 
            helper_dir (Random.self_init (); Random.int 4) 

  
end

module Set_blue_enemy : SetEnemyType = struct
  type t = enemy
  (* Blue enemy uses BFS to choose the bst direction to chase pacman *)
  include BFS
  let get_enemytype = Blue
  let get_sprite = [[(0, 6); (1, 6)]; [(2, 6); (3, 6)]; [(6, 6); (7, 6)]; [(4, 6); (5, 6)]; ]
  let enemy_speed = 0.04

  let move (cur_e : t) (player_pos : (float * float)) : t =  
      let selected_dir = match_dir_to_int (get_best_dir player_pos cur_e.position) in
      let dx, dy = match_dir_to_ind selected_dir in
      let next_x = (fst cur_e.position) +. (dx *. enemy_speed)  in
      let next_y = (snd cur_e.position) +. (dy *. enemy_speed)  in
         (cur_e.position <- check_collsion selected_dir (next_x, next_y);
         cur_e.move_direction <- selected_dir;
         cur_e)
end

module Set_orange_enemy : SetEnemyType = struct
  type t = enemy
  (* Blue enemy uses BFS to chase Pacman and increase the speed over time *)
  include BFS
  let get_enemytype = Orange
  let get_sprite =   [[(0, 7); (1, 7)]; [(2, 7); (3, 7)]; [(6, 7); (7, 7)]; [(4, 7); (5, 7)]; ]
  let enemy_speed = ref 0.04

  let speed_timer = ref 1

  let move (cur_e : t) (player_pos : (float * float)) : t =  
    (if (!speed_timer) mod 50 = 0 then 
      ( speed_timer := 1;
        enemy_speed := !enemy_speed +. 0.005;  )
    else (speed_timer := !speed_timer + 1));
    let selected_dir = match_dir_to_int (get_best_dir player_pos cur_e.position) in
    let dx, dy = match_dir_to_ind selected_dir in
    let next_x = (fst cur_e.position) +. (dx *. !enemy_speed)  in
    let next_y = (snd cur_e.position) +. (dy *. !enemy_speed)  in
       cur_e.position <- check_collsion selected_dir (next_x, next_y);
       cur_e.move_direction <- selected_dir;
       cur_e

end

module Red_enemy : Enemy = MakeEnemy(Set_red_enemy)

module Blue_enemy : Enemy = MakeEnemy(Set_blue_enemy)

module Orange_enemy : Enemy = MakeEnemy(Set_orange_enemy)

module Pink_enemy : Enemy = MakeEnemy(Set_pink_enemy)
open Core
open Random
open Game_map

type enemy_type = Red | Blue | Orange | Pink

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


let match_dir_to_ind dir = 
  match dir with
  | 0 -> (1.0, 0.0)
  | 1 -> (-1.0, 0.0)
  | 2 -> (0.0, 1.0)
  | 3 -> (0.0, -1.0)
  | _ -> failwith "invalid int of direction"

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

  let scared_speed = 0.1
    
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
        match Game_map.get_location (next_x, next_y) with
          | Game_map.Wall -> aux ((d+1) mod 4)
          | _ ->     
            cur_e.position <- (next_x, next_y);
            cur_e.move_direction <- d
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
  (* Red enemy move randomly  *)
  let get_enemytype = Red
  let get_sprite = [[(0, 4); (1, 4)]; [(2, 4); (3, 4)]; [(4, 4); (5, 4)]; [(6, 4); (7, 4)]]
  let enemy_speed = 1.0
  (* TODO: Do I need input map here? use get_location instead *)
  let move (cur_e : t) (player_pos : (float * float)) : t =  
    let rec aux () = 
     let selected_dir = (Random.self_init (); Random.int 4) in 
     let dx, dy = match_dir_to_ind selected_dir in
     let next_x = (fst cur_e.position) +. (dx *. enemy_speed) in
     let next_y = (snd cur_e.position) +. (dy *. enemy_speed) in
      match Game_map.get_location (next_x, next_y) with
      | Game_map.Wall -> aux ()
      | _ ->     
        cur_e.position <- (next_x, next_y);
        cur_e.move_direction <- selected_dir;
        cur_e
    in aux ()   
  
end

module Red_enemy : Enemy = MakeEnemy(Set_red_enemy)
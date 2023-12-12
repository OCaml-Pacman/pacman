open Core

type fruit_type = Common.fruit_type
[@@deriving equal]

type enemy_type = Common.enemy_type
[@@deriving equal]

type item =
  | Wall
  | Ground
  | Enemy of enemy_type
  | Orb
  | BigOrb
  | Player
  | Fruit of fruit_type
[@@deriving equal]

type t = item array array ref

let data : t = ref [| [| Wall |] |]
let raw_data : t = ref [| [| Wall |] |]

let load filename =
  let f_map x =
    match x with
    | "#" -> Wall
    | "." -> Orb
    | "*" -> BigOrb
    | "R" -> Enemy Red
    | "B" -> Enemy Blue
    | "P" -> Enemy Pink
    | "O" -> Enemy Orange
    | "C" -> Player
    | "F" -> Fruit Cherry
    | "G" -> Fruit Strawberry
    | "H" -> Fruit Orange
    | _ -> failwith "Invalid Map"
  in
  try
    data :=
      Csv.load filename |> List.map ~f:Array.of_list |> Array.of_list
      |> Array.map ~f:(Array.map ~f:f_map);
    raw_data := Array.copy !data;
    Array.iteri ~f:(fun index a -> !raw_data.(index) <- Array.copy a) !data;
    true
  with _ -> false

let load_from_data input_data =
  data := Array.copy !input_data;
  raw_data := Array.copy !data

let reload () =
  data := Array.copy !raw_data;
  Array.iteri ~f:(fun index a -> !data.(index) <- Array.copy a) !raw_data

let get_int_size () : int * int =
  let x_max = Array.get !data 0 |> Array.length in
  let y_max = Array.length !data in
  (x_max, y_max)

let get_size () : float * float =
  let x_max, y_max = get_int_size () in
  (Float.of_int x_max, Float.of_int y_max)

(* Get the item at given coordination *)
let get_location (x, y) : item = !data.(Float.to_int y).(Float.to_int x)

(* Update the item at given coordination *)
let change_location (x, y) itm = !data.(Float.to_int y).(Float.to_int x) <- itm

let get_item_count (itm : item) : int =
  Array.fold !data ~init:0 ~f:(fun acc row ->
      acc + Array.count row ~f:(fun i -> equal_item i itm))

let find_player () =
  let found = ref None in
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          if equal_item item Player then
            found := Some (Float.of_int x, Float.of_int y)));
  !found


let is_enemy (item : item) : bool =
  match item with Enemy _ -> true | _ -> false  

let find_enemies () =
  let enemies = ref [] in
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          match item with
          | Enemy enemy -> 
            enemies := ((Float.of_int x, Float.of_int y), enemy) :: !enemies
          | _ -> ()));
  !enemies

let is_fruit (item : item) : bool =
  match item with Fruit _ -> true | _ -> false

let find_fruits () =
  let fruits = ref [] in
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          match item with
          | Fruit fruit ->
              fruits := ((Float.of_int x, Float.of_int y), fruit) :: !fruits
          | _ -> ()));
  !fruits

let find_random_empty () =
  let empty_spaces = ref [] in
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          if equal_item item Ground then empty_spaces := (x, y) :: !empty_spaces));
  match !empty_spaces with
  | [] -> None
  | _ ->
      Some
        (let x, y = List.random_element_exn !empty_spaces in
         (Float.of_int x, Float.of_int y))

let remove_player () =
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          if equal_item item Player then data.contents.(y).(x) <- Ground))

let remove_enemies () =
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          if is_enemy item then data.contents.(y).(x) <- Ground))

let remove_fruits () =
  Array.iteri data.contents ~f:(fun y row ->
      Array.iteri row ~f:(fun x item ->
          if is_fruit item then data.contents.(y).(x) <- Ground))

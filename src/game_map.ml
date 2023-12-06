open Core
type item =
    | Wall
    | Ground
    | Enemy
    | Orb
    | BigOrb
    | Player
    | Fruit [@@deriving equal]

let data : item array array ref = ref [|[|Wall|]|]

let load filename =
  let f_map x = match x with
    | "#" -> Wall
    | "." -> Orb
    | "*" -> BigOrb
    | "R" -> Enemy
    | "B" -> Enemy
    | "P" -> Enemy
    | "O" -> Enemy
    | "C" -> Player
    | _ -> failwith "Invalid Map"
  in
  try
    data := Csv.load filename |> List.map ~f:(Array.of_list) 
            |> Array.of_list |> Array.map ~f:(Array.map ~f:f_map);
    true
  with
    _ -> false


let get_size _ : (float * float) =
  let x_max = Float.of_int (Array.get !data 0 |> Array.length) in
  let y_max = Float.of_int (Array.length !data) in
    (x_max, y_max)

(* Get the item at given coordination *)
let get_location (x,y) : item =
  (!data).(Float.to_int y).(Float.to_int x)

(* Update the item at given coordination *)
let change_location (x,y) itm =
  (!data).(Float.to_int y).(Float.to_int x) <- itm


let get_item_count (itm:item) : int = 
  Array.fold !data ~init:0 ~f:(fun acc row ->
    acc + (Array.count row ~f:(fun i -> equal_item i itm))
  )
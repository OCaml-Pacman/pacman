open Game_map

let wall_sprite = (13, 9)
let ground_sprite = (13,3)
let orb_sprite = (13,1)
let big_orb_sprite = (13,2)
let player_sprite = (0,0);;

Graphics.open_graph " 100x100"

let sprite = ref (Graphics.make_image @@ Array.make_matrix 18 18 Graphics.transp)

let convert_imagelib_to_graphics (img : Image.image) =
  let (w, h) = img.width, img.height in
  let g_img = Array.make_matrix h w Graphics.transp in
  let chan_r = match img.pixels with
  | Grey x -> x
  | GreyA (x,_) -> x
  | RGB (x, _, _) -> x
  | RGBA (x, _, _, _) -> x
  in
  let chan_g = match img.pixels with
  | Grey x -> x
  | GreyA (x,_) -> x
  | RGB (_, x, _) -> x
  | RGBA (_, x, _, _) -> x
  in
  let chan_b = match img.pixels with
  | Grey x -> x
  | GreyA (x,_) -> x
  | RGB (_, _, x) -> x
  | RGBA (_, _, x, _) -> x
  in
  for y = 0 to h - 1 do
    for x = 0 to w - 1 do
      g_img.(y).(x) <- Graphics.rgb (Image.Pixmap.get chan_r x y) (Image.Pixmap.get chan_g x y) (Image.Pixmap.get chan_b x y)
    done
  done;
  Graphics.make_image g_img

let load_sprite path = 
  try
    sprite := convert_imagelib_to_graphics @@ ImageLib_unix.openfile path;
    true
  with 
    _ -> false

let sub_image sheet x_pos y_pos width height transp =
  let sheet_matrix = Graphics.dump_image sheet in
  let sub_matrix = Array.make_matrix height width Graphics.transp in
  for y = 0 to height - 1 do
    for x = 0 to width - 1 do
      let color = sheet_matrix.(y_pos + y).(x_pos + x) in
      sub_matrix.(y).(x) <- (if color = Graphics.black && transp then
        Graphics.transp
      else
        color)
    done
  done;
  Graphics.make_image sub_matrix

(* We need have cache to solve perfomance issue when cutting sprite *)
let sprite_cache = Hashtbl.create 10

let sprite_from_sheet (sheet: Graphics.image) (x: int) (y: int) (transp : bool) =
  try
    (* Find in cache first *)
    Hashtbl.find sprite_cache (x, y, transp)
  with Not_found ->
    (* Cut sprite and save it in cache *)
    let x_pos = x * 16 + 2 in
    let y_pos = y * 16 in
    let sprite = sub_image sheet x_pos y_pos 16 16 transp in
    Hashtbl.add sprite_cache (x, y, transp) sprite;
    sprite

let draw_sprite ?(transp = true) (sx, sy) (x,y) : unit = Graphics.draw_image (sprite_from_sheet !sprite sx sy transp) x y

let set_res _ = 
  let (fx,fy) = get_size () in
  let x = (Float.to_int fx) * 16 in
  let y = (Float.to_int fy) * 16 in
  Graphics.resize_window x y

let coord_map2screen (x,y) = 
  let (_,lim_y) = get_size () in
  let x = Float.mul x 16. |> Float.to_int in
  let y =  (Float.sub lim_y @@ Float.add y 1.) |> Float.mul 16. |> Float.to_int in
  (x, y)

let draw_map _ =
  let (fx,fy) = get_size () in
  let (lim_x,lim_y) = (Float.round fx |> Float.to_int, Float.round fy |> Float.to_int) in
  for x = 0 to lim_x - 1 do
    for y = 0 to lim_y - 1 do
      let map_loc = (Float.of_int x, Float.of_int y) in
      let loc = coord_map2screen map_loc in
      match get_location map_loc with
        | Wall -> draw_sprite ~transp:false wall_sprite loc
        | Ground -> draw_sprite ~transp:false ground_sprite loc
        | Enemy enemy -> draw_sprite ~transp:false (Enemy.get_enemy_sprite_by_type enemy) loc
        | Orb -> draw_sprite ~transp:false orb_sprite loc
        | BigOrb -> draw_sprite ~transp:false big_orb_sprite loc
        | Player -> draw_sprite ~transp:false player_sprite loc
        | Fruit fruit-> draw_sprite ~transp:false (Fruit.get_sprite_from_type fruit) loc
    done
  done

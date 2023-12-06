open Game_map

let wall_sprite = (13, 9)
let ground_sprite = (13,3)
let enemy_sprite = (0,4)
let orb_sprite = (13,1)
let big_orb_sprite = (13,2)
let player_sprite = (0,0)
let fruit_sprite = (2,3);;

Graphics.open_graph ""

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

let load_sprite path = sprite := convert_imagelib_to_graphics @@ ImageLib_unix.openfile path

let sub_image sheet x_pos y_pos width height =
  let sheet_matrix = Graphics.dump_image sheet in
  let sub_matrix = Array.make_matrix height width Graphics.transp in
  for y = 0 to height - 1 do
    for x = 0 to width - 1 do
      sub_matrix.(y).(x) <- sheet_matrix.(y_pos + y).(x_pos + x)
    done
  done;
  Graphics.make_image sub_matrix

let sprite_from_sheet (sheet: Graphics.image) (x: int) (y: int)  = 
  let x_pos = x * 16 + 2 in
  let y_pos = y * 16 in
  sub_image sheet x_pos y_pos 16 16 

let draw_sprite (sx, sy) (x,y) : unit = Graphics.draw_image (sprite_from_sheet !sprite sx sy) x y

let set_res _ = 
  let (fx,fy) = get_size () in
  let x = (Float.to_int fx) * 16 in
  let y = (Float.to_int fy) * 16 in
  Graphics.resize_window x y

let draw_map _ =
  let (fx,fy) = get_size () in
  let (lim_x,lim_y) = (Float.round fx |> Float.to_int, Float.round fy |> Float.to_int) in
  for x = 0 to lim_x - 1 do
    for y = 0 to lim_y - 1 do
      let loc = (x * 16, (lim_y - 1 - y) * 16) in
      let map_loc = (Float.of_int x, Float.of_int y) in
      match get_location map_loc with
        | Wall -> draw_sprite wall_sprite loc
        | Ground -> draw_sprite ground_sprite loc
        | Enemy -> draw_sprite enemy_sprite loc
        | Orb -> draw_sprite orb_sprite loc
        | BigOrb -> draw_sprite big_orb_sprite loc
        | Player -> draw_sprite player_sprite loc
        | Fruit -> draw_sprite fruit_sprite loc
    done
  done

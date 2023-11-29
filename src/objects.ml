type player = {
    position : (float * float);
    sprite : (int * int) list;
    player_state : int
}
type fruit = {
    position : (float * float);
    sprite : (int * int);
}

type enemy_type =
| Red | Blue | Orange | Pink

type enemy = {
    position : (float * float);
    sprite : (int * int) list;
    enemy_state : int;
    enemy_type: enemy_type
}

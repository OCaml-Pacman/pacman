type player_state = Alive | Die

type player = {
    position : (int * int);
    sprite : (int * int);
    player_state : int
}
type fruit = {
    position : (int * int);
    sprite : (int * int);
}

type enemy_state = Alive | Escape | Die

type enemy_type =
| Red | Blue | Orange | Pink

type enemy = {
    position : (int * int);
    sprite : (int * int);
    enemy_state : int;
    enemy_type: enemy_type
}

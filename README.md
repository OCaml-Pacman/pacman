Ocaml PacMan Revamped
=====================

PacMan Revamped is an OCaml-based twist on the classic PacMan game. In this version, players collect orbs and can throw fruits as weapons to hit ghosts, adding a strategic layer to the traditional gameplay.

Getting Started
---------------

### Prerequisites

Before building and running the game, ensure you have the following libraries installed:

*   csv
*   core
*   imagelib.unix
*   graphics

Install these libraries using `opam`:


```sh
opam install csv core imagelib.unix graphics
```


### Building the Project

Build the game using `dune`:

shCopy code

```sh
dune build
```

### Running the Game

After building, run the game with:

```sh
./_build/default/src/main.exe
```

Gameplay
--------

### Objective

Collect all orbs in the maze. Big orbs provide temporary invincibility.

### Controls

*   **Movement**: Use `W`, `A`, `S`, `D` for movement.
*   **Shoot Fruit**: Press `J` to throw fruits.
*   **Restart Game**: Press any key to restart after the game ends.

Libraries and Modules
---------------------

The project includes several OCaml libraries:

*   `game_map`: Game map logic.
*   `render`: Rendering of game elements.
*   `game_state`: Overall game state.
*   `enemy`: Ghost enemy management.
*   `fruit`: Fruit mechanics.
*   `player`: Player character management.

Dependencies are managed as specified in the `dune` file.


Contributions
-------------

Contributions are welcome. Fork the repository, make changes, and submit a pull request.
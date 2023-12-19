(lang dune 3.10)

(generate_opam_files true)

(authors "Qianqi Huang" "Shenghua Chen" "Jiayuan Hu")

(maintainers "qhuang35@jhu.edu" "schen285@jh.edu" "jhu99@jh.edu")

(package
 (name pacman-revamped) ; put in your own project name here
 (synopsis "An OCaml library for revamped Pacman game")
 (description
  "PacMan Revamped is an OCaml-based twist on the classic PacMan game. In this version, players collect orbs and can throw fruits as weapons to hit ghosts, adding a strategic layer to the traditional gameplay.")
 (depends
  (ounit2
   (>= 2.2.7))
  (core
   (>= 0.16.2))
  (graphics
   (>= 5.1.2))
  (csv
   (>= 2.4))
  (imagelib
   (>= 20221222))
  (ppx_jane
   (>= 0.16.0))
  (ppx_deriving
   (>= 5.2.1))
  (bisect_ppx
   (>= 2.8.3))
  (base
   (>= 0.16.3)))
 (allow_empty))

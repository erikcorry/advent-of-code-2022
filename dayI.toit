import .aoc
import .resources

DIRECTIONS ::= [
    [0, 0, 1],
    [0, 0,-1],
    [0, 1, 0],
    [0,-1, 0],
    [1, 0, 0],
    [-1,0, 0],
]

AIR   ::= 0
LAVA  ::= 1
SURROUNDINGS ::= 2

get_surface world -> int:
  surface := 0
  for x := 1; x < 22; x++:
    for y := 1; y < 22; y++:
      for z := 1; z < 22; z++:
        if world[x][y][z] == 1:
          DIRECTIONS.do: | l/List |
            if world[x + l[0]][y + l[1]][z + l[2]] == AIR:
              surface++
  return surface

main:
  world := List 23: List 23: ByteArray 23: AIR
  INPUTI.trim.split "\n":
    split3 it "," (: int.parse it): | x y z |
      world[x + 1][y + 1][z + 1] = LAVA

  part_1_surface := get_surface world
  print part_1_surface

  flood_frontier := [
      [0, 0, 0],
      [22, 0, 0],
      [0, 22, 0],
      [22, 22, 0],
      [0, 0, 22],
      [22, 0, 22],
      [22, 22, 0],
      [22, 22, 22]
  ]

  while flood_frontier.size != 0:
    new_frontier := []
    flood_frontier.do: | l/List |
      x := l[0]
      y := l[1]
      z := l[2]
      DIRECTIONS.do: | d/List |
        nx := x + d[0]
        ny := y + d[1]
        nz := z + d[2]
        if 0 <= nx <= 22 and 0 <= ny <= 22 and 0 <= nz <= 22:
          if world[nx][ny][nz] == AIR:
            new_frontier.add [nx, ny, nz]
            world[nx][ny][nz] = SURROUNDINGS
    flood_frontier = new_frontier

  post_flood_surface := get_surface world

  print part_1_surface - post_flood_surface

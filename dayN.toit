import host.file
import .aoc

DIRECTIONS ::= [[0, -1], [0, 1], [-1, 0], [1, 0]]

DIAGONALS ::= [
    [[-1, -1], [0, -1], [1, -1]],
    [[-1, 1],  [0, 1],  [1, 1]],
    [[-1, -1], [-1, 0], [-1, 1]],
    [[1, -1],  [1, 0],  [1, 1]],
]

class Elf:
  x/int
  y/int
  constructor .x .y:
  hash_code: return x * 9711 + y
  operator == other/Elf: return x == other.x and y == other.y

main:
  lines /List := (file.read_content "inputN.txt").to_string.trim.split "\n"

  world := {}
  for y := 0; y < lines.size; y++:
    line := lines[y]
    for x := 0; x < line.size; x++:
      if line[x] == '#':
        world.add (Elf x y)

  1000000.repeat:
    proposals := {:}
    first_dir := it % 4
    world.do: | elf/Elf |
      decide world elf first_dir: | x y |
        proposals.update (Elf x y) --init=0: it + 1
    new_world := {}
    world.do: | elf/Elf |
      result := decide world elf first_dir: | x y |
        new_elf := Elf x y
        number := proposals[new_elf]
        if number == 1:
          new_world.add new_elf
        else:
          new_world.add elf
      if not result:
        new_world.add elf
    if world == new_world:
      print "Round $(it + 1)"
      return
    world = new_world
    if it == 9:
      minx := lowest_score world: it.x
      maxx := highest_score world: it.x
      miny := lowest_score world: it.y
      maxy := highest_score world: it.y
      print (maxx - minx + 1) * (maxy - miny + 1) - world.size

decide world/Set elf/Elf first_dir/int [block] -> bool:
  if not (DIAGONALS.any: it.any: | xy | world.contains (Elf elf.x+xy[0] elf.y+xy[1])): return false
  for d := first_dir; d < first_dir + 4; d++:
    direction := d % 4
    ok := true
    for i := 0; i < 3; i++:
      xy := DIAGONALS[direction][i]
      dx := xy[0]
      dy := xy[1]
      if world.contains (Elf elf.x+dx elf.y+dy):
        ok = false
    if ok:
      block.call elf.x+DIRECTIONS[direction][0] elf.y+DIRECTIONS[direction][1]
      return true
  return false

import .aoc
import .resources

DIRECTIONS ::= [[0, -1], [0, 1], [-1, 0], [1, 0]]

DIAGONALS ::= [
    [[-1, -1], [0, -1], [1, -1]],
    [[-1, 1],  [0, 1],  [1, 1]],
    [[-1, -1], [-1, 0], [-1, 1]],
    [[1, -1],  [1, 0],  [1, 1]],
]

EIGHT_NEIGHBOURS ::= [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, 1],
    [1, 1],
    [1, 0],
    [1, -1],
    [0, -1],
]

main:
  world := PixelSet
  y := 0
  INPUTN.trim.split "\n": | line |
    for x := 0; x < line.size; x++:
      if line[x] == '#':
        world.add (Coord x y)
    y++

  1000000.repeat:
    if it % 100 == 0: print "Round $it"
    proposals := {:}
    first_dir := it % 4
    world.do: | elf/Coord |
      decide world elf first_dir: | x y |
        proposals.update (Coord x y) --init=0: it + 1
    new_world := PixelSet
    world.do: | elf/Coord |
      result := decide world elf first_dir: | x y |
        new_elf := Coord x y
        number := proposals[new_elf]
        if number == 1:
          new_world.add new_elf
        else:
          new_world.add elf
      if not result:
        new_world.add elf
    if world == new_world:
      print "Part 2: $(it + 1)"
      return
    world = new_world
    if it == 9:
      minx := lowest_score world: it.x
      maxx := highest_score world: it.x
      miny := lowest_score world: it.y
      maxy := highest_score world: it.y
      print "Part 1: $((maxx - minx + 1) * (maxy - miny + 1) - world.size)"

decide world/PixelSet elf/Coord first_dir/int [block] -> bool:
  // An elf that is very alone does not propose any moves.
  if not (EIGHT_NEIGHBOURS.any: | xy | world.contains (Coord elf.x+xy[0] elf.y+xy[1])): return false
  // Try the 4 directions looking for something that is empty.
  for d := first_dir; d < first_dir + 4; d++:
    direction := d % 4
    ok := true
    for i := 0; i < 3; i++:
      xy := DIAGONALS[direction][i]
      dx := xy[0]
      dy := xy[1]
      if world.contains (Coord elf.x+dx elf.y+dy):
        ok = false
        break
    if ok:
      block.call elf.x+DIRECTIONS[direction][0] elf.y+DIRECTIONS[direction][1]
      return true
  return false

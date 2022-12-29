import .resources
import .aoc

// First install the host package with `jag pkg install`.
// Run with `jag run -d host template.toit`

HORIZONTAL ::= [[0, 0], [1, 0], [2, 0], [3, 0]]
STAR       ::= [[1, 0], [0, 1], [1, 1], [1, 2], [2, 1]]
JAY        ::= [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2]]
VERTICAL   ::= [[0, 0], [0, 1], [0, 2], [0, 3]]
SQUARE     ::= [[0, 0], [1, 0], [0, 1], [1, 1]]

ORDER ::= [HORIZONTAL, STAR, JAY, VERTICAL, SQUARE]

WIDTH ::= 7

class Rock:
  coords /List

  constructor l/List y_offset/int:
    coords = l.map: Coord it[0]+2 y_offset + it[1]

  constructor.private_ .coords:

  move dx dy -> Rock:
    new_coords := []
    coords.do:
      new_coords.add (Coord it.x+dx it.y+dy)
    return Rock.private_ new_coords

  can_fall world/Set -> bool:
    return can_go world 0 -1

  can_right world/Set -> bool:
    return can_go world 1 0

  can_left world/Set -> bool:
    return can_go world -1 0

  can_go world/Set dx/int dy/int:
    if (coords.any: it.y + dy <= 0): return false
    if (coords.any: it.x + dx >= WIDTH): return false
    if (coords.any: it.x + dx < 0): return false
    if (coords.any: world.contains (Coord it.x+dx it.y+dy)): return false
    return true

print_world world/Set -> none:
  print ""
  for y := (highest_score world: it.y); y >= 0; y--:
    ba := ByteArray 7: ' '
    world.do: | coord/Coord |
      if not 0 <= coord.x < WIDTH: throw "out of range"
      if coord.y == y:
        ba[coord.x] = '#'
    print "|$ba.to_string|"

main:
  line /string := INPUTH.trim

  stack_heights := List line.size: -1
  rock_numbers := List line.size: -1

  world := {}

  wind_index := 0

  print "line.size = $line.size"

  results := []

  4881.repeat: | rock_number |
    rock_numbers[(wind_index) % line.size] = rock_number
    start_y := ?
    if world.size == 0:
      start_y = 4
    else:
      h := highest_score world: it.y
      if rock_number == 2022 or rock_number == 3160 or rock_number == 4880:
        results.add "Height for $rock_number: $h"
      start_y = h + 4
    rock := Rock ORDER[rock_number % ORDER.size] start_y
    while true:
      h2 := highest_score world: it.y
      stack_heights[wind_index % line.size] = h2
      if line[wind_index++ % line.size] == '<':
        if rock.can_left world:
          rock = rock.move -1 0
      else:
        if rock.can_right world:
          rock = rock.move 1 0
      if rock.can_fall world:
        rock = rock.move 0 -1
      else:
        break
    rock.coords.do: world.add it
    hnow := highest_score world: it.y
    hprev := stack_heights[(wind_index) % line.size]
    old_rock_number := rock_numbers[(wind_index) % line.size]
    print "height diff: $(hnow - hprev) rock diff: $(rock_number - old_rock_number)"

  print (results.join "\n")

section world/Set from/int to/int -> Set:
  result := {}
  world.do: | c/Coord |
    if from <= c.y < to:
      result.add (Coord c.x c.y-from)
  return result

setcopy world/Set -> Set:
  result := {}
  world.do: result.add it
  return result

import host.file
import .aoc

class Field:
  lines_ /List

  constructor:
    lines_ = (file.read_content "inputC.txt").to_string.trim.split "\n"

  position_of needle/string -> Coord:
    lines_.size.repeat: | y |
      idx := lines_[y].index_of needle
      if idx >= 0: return Coord idx y
    unreachable

  elevation x/int y/int -> int:
    c := lines_[y][x]
    if 'a' <= c <= 'z': return c - 'a'
    if c == 'S': return 0
    if c == 'E': return 'z' - 'a'
    unreachable

  height -> int: return lines_.size
  width -> int: return lines_[0].size

  four_dirs c/Coord -> List:
    result := []
    if c.x > 0: result.add (Coord c.x - 1 c.y)
    if c.y > 0: result.add (Coord c.x c.y - 1)
    if c.x < width - 1: result.add (Coord c.x + 1 c.y)
    if c.y < height - 1: result.add (Coord c.x c.y + 1)
    return result

main:
  field := Field

  start := field.position_of "S"
  end := field.position_of "E"

  from_start_distances := calculate_distances field start: | neighbour_elevation elevation | neighbour_elevation - elevation < 2
  print from_start_distances[end.y][end.x]

  from_end_distances   := calculate_distances field end:   | neighbour_elevation elevation | neighbour_elevation - elevation > -2
  best := 1_000_000
  field.height.repeat: | y |
    field.width.repeat: | x |
      dist := from_end_distances[y][x]
      if dist and dist < best and (field.elevation x y) == 0:
        best = dist
  print best

calculate_distances field/Field start/Coord [can_move_block] -> List:
  shortest := List field.height: List field.width: null
  shortest[start.y][start.x] = 0

  work_list := Deque
  work_list.add start

  while work_list.size != 0:
    here := work_list.remove_first
    elevation := field.elevation here.x here.y
    short/int := shortest[here.y][here.x]
    (field.four_dirs here).do: | neighbour/Coord |
      neighbour_elevation := field.elevation neighbour.x neighbour.y
      if can_move_block.call neighbour_elevation elevation:
        old_shortest := shortest[neighbour.y][neighbour.x]
        if old_shortest == null or old_shortest > short + 1: 
          shortest[neighbour.y][neighbour.x] = short + 1
          work_list.add neighbour
  return shortest

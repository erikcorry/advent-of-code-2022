import host.file

class Coordinate:
  x /int
  y /int

  constructor .x .y:

  hash_code :
    return x * 1237 + y * 7

  operator == other/Coordinate -> bool:
    return other.x == x and other.y == y

main:
  run 2
  run 10

run knot_count/int -> none:
  grid := Set
  knots := List knot_count: Coordinate 0 0
  (file.read_content "input9.txt").to_string.trim.split "\n": | line/string |
    (int.parse line[2..]).repeat:
      dx := line[0] == 'L' ? -1 : line[0] == 'R' ? 1 : 0
      dy := line[0] == 'D' ? -1 : line[0] == 'U' ? 1 : 0
      head := knots[0]
      knots[0] = Coordinate (head.x + dx) (head.y + dy)
      for idx := 1; idx < knots.size; idx++:
        current := knots[idx]
        previous := knots[idx - 1]
        if (current.x - previous.x).abs > 1 or (current.y - previous.y).abs > 1:
          knots[idx] = Coordinate
            current.x + (previous.x - current.x).sign
            current.y + (previous.y - current.y).sign
      grid.add
          knots[knots.size - 1]
  print grid.size

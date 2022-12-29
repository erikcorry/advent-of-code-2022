import .aoc
import .resources

main:
  run 2
  run 10

// We would like to use the Coord class, but a set with 5858
// Coord instances is just too big for an ESP32.  The coord
// class has two integer fields and a header, so it's 3 words.
//
// The set adds at least two words per entry: One for the pointer
// to the Coord instance, and one for the index entry.  See
// https://blog.toit.io/hash-maps-that-dont-hate-you-1a96150b492a
//
// In practice the index can only be of a size that is a power of
// two, and it needs some slack, so the minimum size of the index
// is 112.5% of the number of entries, and the max is 225%.
// In effect we need max 7 words per Coord for the set, which is
// 164k - too much for our poor ESP32.
//
// Instead, we encode the coordinate as an integer.  Integers up
// to about 1 billion are tagged pointers that don't cause independent
// objects to be created.  But instead of using these encoded
// integers, we make a special kind of set that encodes objects
// into integers before inserting them.  As it happens, we never take
// objects out of the set in this application, so we don't need to
// implement decoding the integers and reifying the Coord objects.
class CoordSet:
  set_ /Set := {}

  add c/Coord -> none:
    set_.add
        encode_ c.x c.y

  size -> int: return set_.size

  encode_ x/int y/int -> int:
    if not -1000 <= x <= 30000 or not -1000 <= y <= 30000: throw "Can't encode $x, $y"
    return 1000 + x + (1000 + y) * 30000

run knot_count/int -> none:
  grid := CoordSet
  knots := List knot_count: Coord 0 0
  INPUT9.trim.split "\n": | line/string |
    (int.parse line[2..]).repeat:
      dx := line[0] == 'L' ? -1 : line[0] == 'R' ? 1 : 0
      dy := line[0] == 'D' ? -1 : line[0] == 'U' ? 1 : 0
      head := knots[0]
      knots[0] = Coord (head.x + dx) (head.y + dy)
      for idx := 1; idx < knots.size; idx++:
        current := knots[idx]
        previous := knots[idx - 1]
        if (current.x - previous.x).abs > 1 or (current.y - previous.y).abs > 1:
          knots[idx] = Coord
            current.x + (previous.x - current.x).sign
            current.y + (previous.y - current.y).sign
      grid.add
          knots[knots.size - 1]
  print grid.size

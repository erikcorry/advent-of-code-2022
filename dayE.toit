import host.file

class Coord:
  x /int
  y /int

  constructor .x .y:

  operator == other:
    return other is Coord and other.x == x and other.y == y

  hash_code:
    return x * 12317 + y * 43

main:
  run --floor=false
  run --floor=true

run --floor:
  set := {}
  lines /List := (file.read_content "inputE.txt").to_string.trim.split "\n"
  lines.do:
    prev := null
    it.split " -> ": | pair/string |
      nums := (pair.split ",").map: int.parse it
      current := Coord nums[0] nums[1]
      if prev == null:
        prev = current
      else:
        x := current.x
        y := current.y
        while x != prev.x or y != prev.y:
          set.add (Coord x y)
          x += (prev.x - current.x).sign
          y += (prev.y - current.y).sign
        set.add prev
        prev = current

  max_y := set.reduce --initial=set.first.y: | a b | max a b.y

  for counter := 0; true; counter++:
    sand /Coord? := Coord 500 0
    if set.contains sand:
      print counter
      return
    while sand:
      if sand.y > max_y + 3:
        print counter
        return
      for i := 0; i < ORDER.size; i++:
        d/Coord? := ORDER[i]
        if d:
          probe := Coord (sand.x + d.x) (sand.y + d.y)
          if not (set.contains probe or (floor and probe.y == max_y + 2)):
            sand = probe
            break
        else:
          set.add sand
          sand = null

ORDER ::= [
    Coord 0 1,
    Coord -1 1,
    Coord 1 1,
    null
    ]

import .aoc
import .resources

main:
  run --floor=false
  run --floor=true

run --floor:
  set := PixelSet
  INPUTE.trim.split "\n":
    prev := null
    it.split " -> ": | pair/string |
      split2 pair "," (: int.parse it): | x y |
        current := Coord x y
        if prev == null:
          prev = current
        else:
          x = current.x
          y = current.y
          while x != prev.x or y != prev.y:
            set.add (Coord x y)
            x += (prev.x - current.x).sign
            y += (prev.y - current.y).sign
          set.add prev
          prev = current

  max_y := highest_score set: it.y

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

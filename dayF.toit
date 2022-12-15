import host.file
import .aoc

// First install the host package with `jag pkg install`.
// Run with `jag run -d host template.toit`

main:
  lines /List := (file.read_content "inputF.txt").to_string.trim.split "\n"
  beacons := Set  // Places that have a beacon.
  sensors := Map
  lines.do:
    split2 it ": ": | sensor beacon |
      sx := 0
      sy := 0
      bx := 0
      by := 0
      split4 sensor " ": | _ _ x_equals y_equals |
        sx = int.parse x_equals[2..x_equals.size - 1]
        sy = int.parse y_equals[2..]
      split6 beacon " ": | _ _ _ _ x_equals y_equals |
        bx = int.parse x_equals[2..x_equals.size - 1]
        by = int.parse y_equals[2..]
      beacons.add (Coord bx by)
      sensors[Coord sx sy] = Coord bx by

  part1 beacons sensors
  part2 beacons sensors

part1 beacons sensors:
  cant_contain := Set  // Places that can't have a beacon on line 2_000_000
  sensors.do: | s b |
    diamond_width := (s.manhattan b)
    width := diamond_width - (s.y - 2_000_000).abs
    if width >= 0:
      for x := -width; x <= width; x++:
        cant_contain.add s.x+x

  print "Part 1: $(count cant_contain: not beacons.contains (Coord it 2_000_000))"

add_cand set/Set coord/Coord:
  if 0 <= coord.x <= 4_000_000 and 0 <= coord.y <= 4_000_000:
    set.add coord

part2 beacons sensors:
  candidates := []
  is_traced := Set
  sensors.do: | sensor1 beacon1 |
    sensors.do: | sensor2 beacon2 |
      m1 := sensor1.manhattan beacon1
      m2 := sensor2.manhattan beacon2
      sdist := sensor1.manhattan sensor2
      if m1 + m2 + 2 == sdist:
        if not is_traced.contains sensor1 and not is_traced.contains sensor2:
          cand := Set
          if m1 < m2:
            is_traced.add sensor1
            (m1 + 2).repeat: | x |
              y := m1 + 1 - x
              add_cand cand (Coord (sensor1.x + x) (sensor1.y + y))
              add_cand cand (Coord (sensor1.x - x) (sensor1.y + y))
              add_cand cand (Coord (sensor1.x + x) (sensor1.y - y))
              add_cand cand (Coord (sensor1.x - x) (sensor1.y - y))
          else:
            is_traced.add sensor2
            (m2 + 2).repeat: | x |
              y := m2 + 1 - x
              add_cand cand (Coord (sensor2.x + x) (sensor2.y + y))
              add_cand cand (Coord (sensor2.x - x) (sensor2.y + y))
              add_cand cand (Coord (sensor2.x + x) (sensor2.y - y))
              add_cand cand (Coord (sensor2.x - x) (sensor2.y - y))
          candidates.add cand
          print "Added $cand.size candidates"
  candidates.do: | set1/Set |
    candidates.do: | set2/Set |
      if not identical set1 set2:
        intersection/Set := set1.intersect set2
        intersection.do: | candidate/Coord |
          ok := true
          sensors.do: | sensor/Coord beacon/Coord |
            manhattan := sensor.manhattan beacon
            if (sensor.manhattan candidate) < manhattan: ok = false
          if ok: print "Part 2: $(candidate.x * 4_000_000 + candidate.y)"

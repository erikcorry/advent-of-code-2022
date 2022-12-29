import .aoc
import .resources

main:
  groups := (INPUT1.trim.split "\n\n").map: it.split "\n"
  calories := groups.map: sum it: int.parse it
  sorted := calories.sort: | a b | b - a
  print sorted[0]
  print (sum sorted[0..3])

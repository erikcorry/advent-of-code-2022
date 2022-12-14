import host.file
import .aoc

main:
  groups := ((file.read_content "input1.txt").to_string.trim.split "\n\n").map: it.split "\n"
  calories := groups.map: sum it: int.parse it
  sorted := calories.sort: | a b | b - a
  print sorted[0]
  print (sum sorted[0..3])

import host.file

sum elf/List -> int:
  return elf.reduce --initial=0: | a b | a + (int.parse b)

main:
  biggest := 0
  current := 0
  elves := []
  lines := (file.read_content "input1.txt").to_string.split "\n"
  previous_gap := -1
  while true:
    gap := lines.index_of "" (previous_gap + 1) --if_absent=:
      elves.add (sum lines[previous_gap + 1..])
      break
    elves.add (sum lines[previous_gap + 1..gap])
    previous_gap = gap
  sorted := elves.sort: | a b | b - a
  print sorted[0]
  print sorted[0] + sorted[1] + sorted[2]

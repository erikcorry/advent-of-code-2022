import host.file

main:
  run: it[1][0] <= it[0][0] <= it[0][1] <= it[1][1] or it[0][0] <= it[1][0] <= it[1][1] <= it[0][1]
  run: it[0][0] <= it[1][0] <= it[0][1]             or it[1][0] <= it[0][0] <= it[1][1]

run [predicate]:
  print ((((file.read_content "input4.txt").to_string.trim.split "\n").map: | line | ((line.split ",").map: | elf | (elf.split "-").map: int.parse it)).reduce --initial=0: | a b | a + ((predicate.call b) ? 1 : 0))

import host.file
import .aoc

main:
  part1
  part2

part1:
  total := 0
  (file.read_content "input3.txt").to_string.trim.split "\n": | line |
    left := line[..line.size / 2].to_byte_array
    line[line.size / 2..].do: | char |
      if (left.index_of char) >= 0:
        total += priority char
        continue.split
  print total

part2:
  lines := (file.read_content "input3.txt").to_string.trim.split "\n"
  print
    sum
      ((group 3 lines).map: (bitand it: bitmap it)).map: it.count_trailing_zeros

priority char/int -> int:
  if char <= 'Z': return char - 'A' + 27
  return char - 'a' + 1

bitmap str/string -> int:
  result := 0
  str.do: result |= 1 << (priority it)
  return result

import host.file

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
  total := 0
  lines := (file.read_content "input3.txt").to_string.trim.split "\n"
  for i := 0; i < lines.size; i += 3:
    l1 := bitmap lines[i]
    l2 := bitmap lines[i + 1]
    l3 := bitmap lines[i + 2]
    common := l1 & l2 & l3
    total += common.count_trailing_zeros
  print total

priority char/int -> int:
  if char <= 'Z': return char - 'A' + 27
  return char - 'a' + 1

bitmap str/string -> int:
  result := 0
  str.do: result |= 1 << (priority it)
  return result

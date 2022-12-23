import host.file
import .aoc

class Number:
  value /int

  constructor .value:

  stringify: return "$value"

main:
  run 1 1
  run 811589153 10

run multiplier iterations:
  number_strings /List := (file.read_content "inputK.txt").to_string.trim.split "\n"
  zero := null
  numbers /List := List number_strings.size:
    obj := Number multiplier * (int.parse number_strings[it])
    if obj.value == 0: zero = obj
    obj

  NUMBERS_SIZE ::= numbers.size

  iteration_order /List := numbers.copy

  iterations.repeat:
    print it
    iteration_order.do: | n/Number |
      current_position := numbers.index_of n
      distance := mod n.value (NUMBERS_SIZE * (NUMBERS_SIZE - 1))
      pos := current_position

      // For very high numbers of rotations we can rotate all the numbers
      // except the current one by the div, and then just do the mod.
      high_level_rotations := distance / NUMBERS_SIZE
      distance %= NUMBERS_SIZE

      other_numbers := numbers[current_position + 1..] + numbers[..current_position]
      other_numbers = other_numbers[high_level_rotations..] + other_numbers[..high_level_rotations]
      numbers = other_numbers[other_numbers.size - current_position..] + [n] + other_numbers[..other_numbers.size - current_position]
      distance.repeat:
        mod_pos := pos % NUMBERS_SIZE
        next_pos := (pos + 1) % NUMBERS_SIZE
        numbers[mod_pos] = numbers[next_pos]
        pos++
      resting_place := (current_position + distance) % NUMBERS_SIZE
      numbers[resting_place] = n
  sum := 0
  zero_position := numbers.index_of zero
  sum += numbers[(zero_position + 1000) % NUMBERS_SIZE].value
  sum += numbers[(zero_position + 2000) % NUMBERS_SIZE].value
  sum += numbers[(zero_position + 3000) % NUMBERS_SIZE].value
  print sum

// Mod that always returns a positive number.
mod x n:
  result := x % n
  if result < 0: result += n
  return result

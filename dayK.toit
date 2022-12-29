import .aoc
import .resources

class Number:
  value /int

  constructor .value:

  stringify: return "$value"

main:
  run 1 1
  run 811589153 10

run multiplier iterations:
  size := 0
  INPUTK.trim.split "\n": size++
  numbers /List := List size
  zero := null
  index := 0
  INPUTK.trim.split "\n":
    obj := Number multiplier * (int.parse it)
    if obj.value == 0: zero = obj
    numbers[index++] = obj

  iteration_order /List := numbers.copy

  iterations.repeat:
    print it
    iteration_order.do: | n/Number |
      current_position := numbers.index_of n
      distance := mod n.value (size * (size - 1))
      pos := current_position

      // For very high numbers of rotations we can rotate all the numbers
      // except the current one by the div, and then just do the mod.
      high_level_rotations := distance / size
      distance %= size

      other_numbers := numbers[current_position + 1..] + numbers[..current_position]
      other_numbers = other_numbers[high_level_rotations..] + other_numbers[..high_level_rotations]
      numbers = List size
      part1 := other_numbers[other_numbers.size - current_position..]
      part3 := other_numbers[..other_numbers.size - current_position]
      numbers.replace 0 part1
      numbers[part1.size] = n
      numbers.replace (part1.size + 1) part3
      distance.repeat:
        mod_pos := pos % size
        next_pos := (pos + 1) % size
        numbers[mod_pos] = numbers[next_pos]
        pos++
      resting_place := (current_position + distance) % size
      numbers[resting_place] = n
  sum := 0
  zero_position := numbers.index_of zero
  sum += numbers[(zero_position + 1000) % size].value
  sum += numbers[(zero_position + 2000) % size].value
  sum += numbers[(zero_position + 3000) % size].value
  print sum

// Mod that always returns a positive number.
mod x n:
  result := x % n
  if result < 0: result += n
  return result

import host.file

class Monkey:
  items /List := []

  // Too lazy to make a real expression parser, so we just recognize a few patterns and set these three fields.
  op_add /int
  op_mul /int
  op_square /bool

  modulus /int
  true_index /int
  false_index /int
  count := 0

  constructor --.items --.modulus --.true_index --.false_index --.op_add --.op_mul --.op_square:

  operation value/int -> int:
    result := (value + op_add) * op_mul
    if op_square: result *= result
    return result

  process monkeys/List reduction/int --divide/bool -> none:
    items.do: | worry/int |
      count++
      worry = operation worry
      if divide:
        worry /= 3
      else:
        worry %= reduction
      if worry % modulus == 0:
        monkeys[true_index].items.add worry
      else:
        monkeys[false_index].items.add worry
    items = []

last_number str/string:
  return int.parse str[(str.index_of --last " ") + 1..]

main:
  run 20 --divide=true
  run 10_000 --divide=false

run iterations/int --divide/bool:
  monkeys ::= []

  (file.read_content "inputB.txt").to_string.trim.split "\n\n":
    lines := it.split "\n"
    items := ((lines[1].split ": ")[1].split ", ").map: int.parse it
    // Line 2 is the expression.  Instead of an expression parser we just
    // recognize the three patterns.
    op_add := (lines[2].contains "+") ? (last_number lines[2]) : 0
    op_mul := ?
    op_square := ?
    if lines[2].ends_with "old * old":
      op_mul = 1
      op_square = true
    else:
      op_mul = (lines[2].contains "*") ? (last_number lines[2]) : 1
      op_square = false

    modulus := last_number lines[3]
    monkeys.add
        Monkey
            --items=items
            --modulus=modulus
            --true_index=last_number lines[4]
            --false_index=last_number lines[5]
            --op_add=op_add
            --op_mul=op_mul
            --op_square=op_square
  reduction := monkeys.reduce --initial=1: | r monkey | r *= monkey.modulus
  iterations.repeat:
    monkeys.do: it.process monkeys reduction --divide=divide
  most_active := (monkeys.sort: | a b | b.count - a.count)[..2]
  print most_active[0].count * most_active[1].count

import host.file
import .aoc

class Monkey:
  value /int? := null
  reset_value /int? := null
  name /string

  stringify: return name

  operator == other/Monkey -> bool:
    return name == other.name

  hash_code -> int: return name.hash_code

  constructor .name .reset_value:

  constructor .name .operation .inputs:

  inputs /List := []
  outputs /List := []
  operation /int := 0

  eval -> none:
    if (inputs.every: it.value):
      if operation < '-':
        if operation == '*':
          value = inputs[0].value * inputs[1].value
        else if operation == '+':
          value = inputs[0].value + inputs[1].value
        else:
          unreachable
      else:
        if operation == '-':
          value = inputs[0].value - inputs[1].value
        else if operation == '/':
          value = inputs[0].value / inputs[1].value
        else:
          unreachable

  // One_input is one of the inputs of this.
  // The other input knows its value.
  // Returns the value that one_input should have for the correct result to be calculated.
  // Asks the output of this (there can be only one) what the result of the calculation
  // should be.
  find_input one_input/Monkey:
    other_index := inputs[0] == one_input ? 1 : 0
    other_input/Monkey := inputs[other_index]
    if name == "root":
      // In part 2, the root just checks both sides are equal so we
      // just use the other input as the desired value.  Terminates
      // the recursion.
      return other_input.value
    if outputs.size != 1: throw "Uh-oh, two outputs for this monkey"
    desired_result := outputs[0].find_input this  // Recurse.
    // Solve the calculation.
    if operation == '+':
      return desired_result - other_input.value
    if operation == '-':
      if other_index == 0:
        // Return the value that the rhs should have.
        return other_input.value - desired_result
      else:
        // Return the value that the lhs should have.
        return desired_result + other_input.value
    if operation == '*':
      if desired_result % other_input.value != 0:
        throw "Wanted a number x so that x * $other_input.value == $desired_result"
      return desired_result / other_input.value
    if operation == '/':
      if other_index == 0:
        // Return the value that the rhs should have.
        return other_input.value / desired_result
      else:
        // Return the value that the lhs should have.
        return desired_result * other_input.value
    unreachable

main:
  flock := {:}
  (file.read_content "inputL.txt").to_string.trim.split "\n": | line |
    split2 line ": ": | name expression |
      if '0' <= expression[0] <= '9':
        flock[name] = Monkey name (int.parse expression)
      else:
        split3 expression " ": | lhs operation rhs |
          flock[name] = Monkey name operation[0] [lhs, rhs]

  // Resolve.
  flock.do --values: | monkey/Monkey |
    monkey.inputs = monkey.inputs.map: flock[it]
    monkey.inputs.do: | up_monkey/Monkey | up_monkey.outputs.add monkey

  // Calculate
  work_list := {}
  flock.do --values: | monkey/Monkey |
    if monkey.reset_value:
      monkey.value = monkey.reset_value
      monkey.outputs.do:
        work_list.add it
    else:
      monkey.value = null

  // Propagate values through the network for part 1.
  while not flock["root"].value:
    new_work_list := {}
    work_list.do: | monkey |
      monkey.eval
      if monkey.value:
        monkey.outputs.do: new_work_list.add it
    work_list = new_work_list

  print flock["root"].value

  // Work backwards for part 2 to work out what humn should shout.
  print
      flock["humn"].outputs[0].find_input flock["humn"]

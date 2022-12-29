import .resources
import .aoc

class Monkey:
  // The value that the monkey is shouting.
  value /int? := null
  // The name and the operation, coded as an integer.
  name_and_operation /int
  // Monkeys that are listening to this monkey.  This
  // can be null (no monkeys are listening), a monkey
  // (one monkey is listening), or a list of monkeys.
  listeners_ := null

  number -> int:
    return name_and_operation >> 7

  operation -> int:
    return name_and_operation & 0x7f

  constructor name/string operation/int .value:
    name_and_operation = ((int.parse --radix=36 name) << 7) + operation

  stringify: return name

  name -> string:
    return (name_and_operation >> 7).stringify 36

  operator == other/Monkey -> bool:
    return name == other.name

  hash_code -> int: return name_and_operation

  listeners -> List:
    if listeners_ == null: return []
    if listeners_ is List: return listeners_
    return [listeners_]

  add_listener monkey/CalculatingMonkey -> none:
    if not listeners_:
      listeners_ = monkey
    else if listeners_ is List:
      listeners_.add monkey
    else:
      listeners_ = monkey

  resolve map/MonkeyMap -> none:

  eval -> none:

  static name_to_number name/string -> int:
    if name.size > 4: throw "Trick only works for short names"
    return int.parse --radix=36 name

  static number_to_name_ name/int -> string:
    return name.stringify /* base = */ 36

class CalculatingMonkey extends Monkey:
  // Initially these are monkey numbers.  After resolution they are references
  // to monkeys.
  input0_ := null
  input1_ := null

  constructor name operation string_input0/string string_input1/string:
    input0_ = Monkey.name_to_number string_input0
    input1_ = Monkey.name_to_number string_input1
    super name operation null

  resolve map/MonkeyMap -> none:
    input0_ = map[input0_]
    input1_ = map[input1_]
    input0_.add_listener this
    input1_.add_listener this

  eval -> none:
    if input0_.value and input1_.value:
      if operation < '-':
        if operation == '*':
          value = input0_.value * input1_.value
        else if operation == '+':
          value = input0_.value + input1_.value
        else:
          unreachable
      else:
        if operation == '-':
          value = input0_.value - input1_.value
        else if operation == '/':
          value = input0_.value / input1_.value
        else:
          unreachable

  // One_input is one of the inputs of this.
  // The other input knows its value.
  // Returns the value that one_input should have for the correct result to be calculated.
  // Makes use of the fact that each monkey in the input only has at most one monkey
  // that is listening to it.
  // Asks the listener of this what the result of the calculation should be.
  find_input one_input/Monkey:
    other_index := input0_ == one_input ? 1 : 0
    other_input/Monkey := other_index == 0 ? input0_ : input1_
    if name == "root":
      // In part 2, the root just checks both sides are equal so we
      // just use the other input as the desired value.  Terminates
      // the recursion.
      return other_input.value
    if listeners.size != 1: throw "Uh-oh, two listeners for this monkey"
    desired_result := listeners[0].find_input this  // Recurse.
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

// A special set that contains monkeys, but you can look up
// a monkey by its number.  This is slightly cheating because
// we override two private methods in Set.
class MonkeySet_ extends Set:
  hash_code_ key:
    if key is int:
      return key
    else:
      return (key as Monkey).number

  compare_ key1 key2 -> bool:
    if key1 is int and key2 is int: throw "Neither is Monkey"
    if key1 is int:
      return key2.number == key1
    else if key2 is int:
      return key1.number == key2
    else:
      return key1.number == key2.number

// Somewhere between a set and a map, it stores only the
// monkeys, but you can look up by the name or number of
// the monkey.
class MonkeyMap:
  set_ /MonkeySet_ := MonkeySet_

  clear -> none:
    set_.clear

  operator[] name:
    if name is string:
      return set_.get (Monkey.name_to_number name)
    else:
      return set_.get (name as int)

  add monkey/Monkey -> none:
    set_.add monkey

  size -> int: return set_.size

  do [block]:
    set_.do block

main:
  flock /MonkeyMap? := MonkeyMap
  INPUTL.trim.split "\n": | line |
    split2 line ": ": | name expression |
      if '0' <= expression[0] <= '9':
        flock.add
            Monkey name 0 (int.parse expression)
      else:
        split3 expression " ": | lhs operation rhs |
          flock.add
              CalculatingMonkey name operation[0] lhs rhs

  flock.do: | monkey/Monkey |
    monkey.resolve flock

  // Calculate
  work_list := flock

  // Propagate values through the network for part 1.
  while not flock["root"].value:
    new_work_list := MonkeyMap
    work_list.do: | monkey |
      while monkey:
        monkey.eval
        if monkey.value:
          listeners := monkey.listeners
          // To save memory on the work list we add all but the last
          // entry to the work list, then iterate on the last entry.
          // This is similar to the trick that limits recursion depth
          // in quicksort, where you iterate on one side and recurse
          // on the other.  As it happens there is always only one
          // listener in my input :-/.
          if listeners.size == 0:
            monkey = null  // Terminate loop.
          else:
            monkey = listeners[0]
            listeners[1..].do: new_work_list.add it
        else:
          monkey = null  // Terminate loop.
    work_list = new_work_list

  print flock["root"].value

  // Work backwards for part 2 to work out what humn should shout.
  print
      flock["humn"].listeners[0].find_input flock["humn"]

import .resources
import .aoc

// About half an hour runtime :-/.

GEODE ::= 0
OBSIDIAN ::= 1
CLAY ::= 2
ORE ::= 3
MINERALS ::= 4

NAMES ::= ["geode", "obsidian", "clay", "ore"]
NUMBERS ::= {"geode": 0, "obsidian": 1, "clay": 2, "ore": 3}

DESCRIBE_STEPS ::= false

class State:
  inventory /List  // Enum to int.
  robots /List     // Enum to int.
  steps /List? := null

  geodes -> int: return inventory[GEODE]

  constructor:
    inventory = [0, 0, 0, 0]
    robots    = [0, 0, 0, 0]
    robots[ORE] = 1

  constructor .robots .inventory .steps:

  stringify -> string: return "inventory: $inventory, robots: $robots"

  operator > other/State:
    return geodes > other.geodes

  max_geode blueprint/Blueprint minutes_left/int best_so_far/State -> State:
    if minutes_left == 0: return this
    // How many geodes can I crack if I do nothing more.
    my_potential := geodes + minutes_left * robots[GEODE]
    if my_potential > best_so_far.geodes:
      new_inventory := List MINERALS:
        inventory[it] + minutes_left * robots[it]
      new_steps := null
      if DESCRIBE_STEPS:
        new_steps = steps + ["Let the time run out for $minutes_left, making another $(minutes_left * robots[GEODE]) geodes"]
      best_so_far = State robots new_inventory new_steps
    else:
      // Add the extra geodes I could crack if we assume a new geode machine
      // arrives every minute from now on.
      my_potential += triangle_number minutes_left - 2
      if my_potential <= best_so_far.geodes:
        return best_so_far
    if minutes_left > 1:
      MINERALS.repeat: | mineral |
        time/int? := blueprint.when_can_i_build mineral this
        if time and time < minutes_left:
          new_inventory := List 4: | r |
            inventory[r] + (time + 1) * robots[r] - blueprint.rules[mineral][r]
          new_robots := robots.copy
          new_robots[mineral]++
          new_steps := null
          if DESCRIBE_STEPS:
            new_steps = steps + ["After $time, spend 1 making $NAMES[mineral] with $(blueprint.describe_recipe mineral), now we have inventory: $new_inventory robots: $new_robots"]
          attempt := (State new_robots new_inventory new_steps).max_geode blueprint (minutes_left - time - 1) best_so_far
          if attempt > best_so_far: best_so_far = attempt
    return best_so_far

// 0 -> 1
// 1 -> 3
// 2 -> 6
triangle_number n/int -> int:
  return ((n + 2) * (n + 1)) >> 1
      
class Blueprint:
  rules /List := List MINERALS  // From mineral enum to (list from mineral type to cost).

  when_can_i_build mineral/int state/State -> int?:
    worst/int := 0
    MINERALS.repeat: | ingredient |
      cost := rules[mineral][ingredient]
      deficit := cost - state.inventory[ingredient]
      if deficit > 0:
        production := state.robots[ingredient]
        if production == 0: return null  // Can never build one with current robots.
        worst = max ((deficit + production - 1) / production) worst  // Round up.
    return worst

  describe_recipe mineral/int -> string:
    answer := []
    MINERALS.repeat: | ingredient/int |
      cost := rules[mineral][ingredient]
      if cost != 0: answer.add "$cost $(NAMES[ingredient])s"
    return answer.join ","

main:
  lines /List := INPUTJ.trim.split "\n"
  total := 0
  line_number := 1
  lines.do: total += line_number++ * (max_geodes it 30)
  print "part1: $total"
  product := 1
  3.repeat: product *= max_geodes lines[it] 32
  print "part2: $product"

max_geodes line/string minutes/int -> int:
  colon := line.index_of ": "
  description := line[colon + 2..line.size - 1]
  blueprint := Blueprint
  description.split ". ": | rule/string |
    if (rule.index_of " and ") < 0:
      split6 rule " ": | _ output _ _ cost input |
        recipe := List MINERALS: 0
        recipe[NUMBERS[input]] = int.parse cost
        blueprint.rules[NUMBERS[output]] = recipe
    else:
      split9 rule " ": | _ output _ _ cost1 input1 _ cost2 input2 |
        recipe := List MINERALS: 0
        recipe[NUMBERS[input1]] = int.parse cost1
        recipe[NUMBERS[input2]] = int.parse cost2
        blueprint.rules[NUMBERS[output]] = recipe

  best_state := (State).max_geode blueprint minutes State
  geodes := best_state.geodes
  if best_state.steps: best_state.steps.do: print it
  print "Best: $best_state"
  print ""
  return geodes

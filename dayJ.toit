import host.file
import .aoc

class State:
  inventory /Map  // Name to int.
  robots /Map     // Name to int.

  constructor:
    inventory = {"ore": 0, "clay": 0, "obsidian": 0, "geode": 0}
    robots    = {"ore": 1, "clay": 0, "obsidian": 0, "geode": 0}

  constructor .robots .inventory:

  stringify -> string: return "inventory: $inventory, robots: $robots"

  hash_code -> int:
    code := 0
    inventory.do: | _ value |
      code *= 97
      code += value
    robots.do: | _ value |
      code *= 97
      code += value
    return code

  operator == other/State:
    inventory.do: | product/string count/int | if other.inventory[product] != count: return false
    robots.do: | product/string count/int | if other.robots[product] != count: return false
    return true

  static produce robots/Map inventory -> Map:
    new_inventory := inventory.copy
    robots.do: | ingredient number |
      new_inventory[ingredient] += number
    return new_inventory

  successors successors/Set blueprint/Blueprint:
    successors.add this
    add_successors_ successors inventory robots blueprint.rules

  is_wasting_time blueprint/Blueprint -> bool:
    // We are wasting time if there is enough ore to make an ore robot or a clay robot, but we don't have any clay robots.
    if robots["clay"] == 0:
      if inventory["ore"] > blueprint.rules[0].requirements["ore"] and inventory["ore"] > blueprint.rules[1].requirements["ore"]: return true
    // We are wasting time if there is enough ore to make an ore robot or a clay robot, but we don't have any obsidian robots.
    if robots["obsidian"] == 0:
      if inventory["ore"] > blueprint.rules[0].requirements["ore"] and inventory["ore"] > blueprint.rules[1].requirements["ore"] and inventory["ore"] > blueprint.rules[2].requirements["ore"] and inventory["clay"] > blueprint.rules[2].requirements["clay"]: return true
    return false

  static add_successors_ successors/Set inventory/Map robots/Map rules/List:
    rules.do: | rule |
      possible := true
      rule.requirements.do: | ingredient/string count/int |
        if inventory[ingredient] < count:
          possible = false
      if possible:
        new_inventory := inventory.copy
        new_robots := robots.copy
        rule.requirements.do: | ingredient/string count/int |
          new_inventory[ingredient] -= count
          new_robots[rule.production]++
        successors.add
          State new_robots new_inventory
        add_successors_ successors new_inventory new_robots rules

class Blueprint:
  id /int
  rules /List := []  // Of Rule.

  constructor .id:

class Rule:
  requirements /Map ::= {:}  // Map from name to cost
  production /string

  constructor .requirements .production:

main:
  lines /List := (file.read_content "inputJ.txt").to_string.trim.split "\n"
  lines.do: run it

run line/string -> none:
  split2 line ": ": | blueprint_name/string description/string |
    blueprint := null
    split2 blueprint_name " ": | _ id |
      blueprint = Blueprint (int.parse id)
    description = description[..description.size - 1]  // Trim dot.
    description.split ". ": | rule/string |
      if (rule.index_of " and ") < 0:
        split6 rule " ": | _ output _ _ cost_str input |
          cost := int.parse cost_str
          blueprint.rules.add (Rule {input: cost} output)
      else:
        split9 rule " ": | _ output _ _ cost1_str input1 _ cost2_str input2 |
          cost1 := int.parse cost1_str
          cost2 := int.parse cost2_str
          blueprint.rules.add (Rule {input1: cost1, input2: cost2} output)

    states := {State}

    24.repeat: | minute |
      print "Round $minute, $states.size states"
      next := {}
      states.do: | state |
        after_robot_production := {}
        state.successors after_robot_production blueprint
        after_robot_production.do: | after |
          next.add (State after.robots (State.produce state.robots after.inventory) )
      states = next.filter: not it.is_wasting_time blueprint

    print blueprint.id * (highest_score states: it.inventory["geode"])

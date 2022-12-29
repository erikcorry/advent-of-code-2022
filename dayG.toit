import .aoc
import .resources

class Positions:
  positions /List

  constructor.initial position/int --players/int:
    positions = List players: position

  constructor.move predecessor/Positions index/int new_position/int:
    positions = predecessor.positions.copy
    positions[index] = new_position

  size -> int: return positions.size

  operator [] index/int: return positions[index]

  operator == other/Positions:
    if positions.size != other.positions.size: throw "mismatch"
    if positions == other.positions: return true
    if positions.size == 1: return false
    if positions.size != 2: throw "Unimplemented"
    return positions[0] == other.positions[1] and positions[1] == other.positions[0]

  hash_code -> int:
    if positions.size == 1: return positions[0]
    if positions.size != 2: throw "Unimplemented"
    if positions[0] < positions[1]:
      return positions[0] * 1237 + positions[1]
    return positions[1] * 1237 + positions[0]

  stringify -> string:
    return "<$((positions.map: it.stringify).join ",")>"

  lexically_compare other/Positions -> int:
    if positions.size != other.positions.size: throw "mismatch"
    if positions.size == 1: return positions[0] - other.positions[0]
    if positions.size != 2: throw "Unimplemented"
    copy := positions.sort
    othercopy := other.positions.sort
    if copy[0] == othercopy[0]:
      return copy[1] - othercopy[1]
    return copy[0] - othercopy[0]

class Status:
  position /Positions
  pressure_released/int
  opened/int // mask
  remaining_pressure/int
  position_chain := []
  places_players_have_been_since_last_opening_a_tap /List

  constructor.open --remaining_rounds/int prev/Status opening_position/int position_index/int --world/World:
    if not (prev.can_open opening_position world): throw "waa"
    // We have a tap we haven't already opened, and it releases a non-zero pressure.
    pressure_released = prev.pressure_released + world.flowrates[opening_position] * (remaining_rounds - 1)
    remaining_pressure = prev.remaining_pressure - world.flowrates[opening_position]
    opened = prev.opened | (1 << opening_position)
    position_chain = prev.position_chain + ["Opened valve at $world.names[opening_position] releasing $world.flowrates[opening_position] with $(remaining_rounds - 1) to go, giving $(pressure_released) in all"]
    position = prev.position
    places_players_have_been_since_last_opening_a_tap = prev.places_players_have_been_since_last_opening_a_tap
    places_players_have_been_since_last_opening_a_tap[position_index] = 1 << opening_position

  constructor.move prev/Status new_position/int position_index/int --names/Map:
    pressure_released = prev.pressure_released
    remaining_pressure = prev.remaining_pressure
    opened = prev.opened
    position_chain = prev.position_chain // prev.position_chain + ["Moved player $position_index to $names[new_position]"]
    position = Positions.move prev.position position_index new_position
    places_players_have_been_since_last_opening_a_tap = prev.places_players_have_been_since_last_opening_a_tap.copy
    places_players_have_been_since_last_opening_a_tap[position_index] |= 1 << new_position

  constructor.initial start_position/int total_pressure/int --players/int:
    remaining_pressure = total_pressure
    pressure_released = 0
    opened = 0
    position = Positions.initial start_position --players=players
    places_players_have_been_since_last_opening_a_tap = List players: 0

  has_been position/int position_index/int -> bool:
    return places_players_have_been_since_last_opening_a_tap[position_index] & (1 << position) != 0

  stringify: return "score=$pressure_released/opened=$(%b opened)@$position"

  can_open pos/int world/World -> bool:
    return world.flowrates[pos] != 0 and opened & (1 << pos) == 0

  other_is_clearly_better other/Status --remaining_rounds/int:
    if position != other.position: throw "can't compare"
    if pressure_released <= other.pressure_released:
      if remaining_rounds <= 2: return true  // No time to catch up.
      potential := (remaining_rounds - 2) * remaining_pressure
      if pressure_released + potential <= other.pressure_released:
        return true  // No potential to catch up.
    if other.opened | opened == opened:
      // The other hasn't opened taps that we have saved for later.
      return other.pressure_released >= pressure_released
    if other.opened | opened == other.opened:
      // The other has opened more taps.
      return false
    if (other.opened ^ opened).population_count == 2:
      // We opened one tap and they opened another that we don't have in common.
      if other.opened > opened:
        // The taps are ordered with the best taps in the low bits, so this means
        // they opened a worse tap.  If they nevertheless got more points that's
        // clear win.
        return other.pressure_released >= pressure_released
    return false

main:
  world := World
  world.run 30 --players=1
  world.run 26 --players=2

class World:
  lines /List := INPUTG.trim.split "\n"
  valves := {:} // From name to bit position.
  names := {:}  // From bit position to name.
  flowrates := []
  dests := []
  total_pressure := 0
  potential_by_remains := []

  constructor:
    lines.do:
      split2 it "; ": | valvedesc |
        split5 valvedesc " ": | _ valvename _ _ ratestring |
          names[valves.size] = valvename
          valves[valvename] = valves.size
          split2 ratestring "=": | _ r |
            rate := int.parse r
            flowrates.add rate
            total_pressure += rate
    lines.do:
      split2 it "; ": | _ tunneldesc |
        split_up_to 5 tunneldesc " ": | _ _ _ _ ds |
          dests.add
              (ds.split ", ").map: valves[it]

  generate_successors predecessor/Status index/int --players/int --remaining_rounds/int -> List:
    new_statuses := []
    dests[predecessor.position[index]].do: | dest/int |
      if not predecessor.has_been dest index:
        moved := Status.move predecessor dest index --names=names
        new_statuses.add moved
    if predecessor.can_open predecessor.position[index] this:
      opened := Status.open --remaining_rounds=remaining_rounds predecessor predecessor.position[index] index --world=this
      new_statuses.add opened
    index++
    if index == players:
      return new_statuses
    return join_arrays (new_statuses.map: generate_successors it index --players=players --remaining_rounds=remaining_rounds)

  run iterations/int --players/int:
    start := Status.initial valves["AA"] total_pressure --players=players
    current := [start]
    hall_of_fame := null
    best := -1
    iterations.repeat: | round |
      print "$round: $current.size candidates"
      next_gen := []
      rem := iterations - round
      current.do: | status/Status |
        (generate_successors status 0 --players=players --remaining_rounds=rem).do: next_gen.add it

      // Remove those at each position that have opened the same taps, but are behind.
      best_score_by_position := {:}
      next_gen.do: | a |
        if a.remaining_pressure == 0:
          if a.pressure_released > best:
            print a.pressure_released
            best = a.pressure_released
        if best_score_by_position.contains a.position:
          best_so_far := best_score_by_position[a.position]
          if best_so_far < a.pressure_released:
            best_score_by_position[a.position] = a.pressure_released
        else:
          best_score_by_position[a.position] = a.pressure_released
      next_gen.sort --in_place: | a b |
          // Sort by 1) position 2) which taps are open 3) descending pressure_released.
          pd := a.position.lexically_compare b.position
          if pd != 0:
            pd
          else:
            ao := b.opened - a.opened
            if ao != 0:
              ao
            else:
              b.pressure_released - a.pressure_released
      index_of_best_of_each_tap_config := -1
      current_position := Positions.initial -1 --players=players
      current_opened := -1
      current = []
      for i := 0; i < next_gen.size; i++:
        candidate := next_gen[i]
        if false and candidate.remaining_pressure == 0:
          if hall_of_fame == null:
            hall_of_fame = candidate
          else:
            if candidate.pressure_released > hall_of_fame.pressure_released:
              hall_of_fame = candidate
          continue
        if current_position == candidate.position:
          if current_opened == candidate.opened:
            continue  // Only need the best of those in the same place with the same opened list.
          current_opened = candidate.opened
          // Same room, but new tap config.
          dealt_with := false
          for j := index_of_best_of_each_tap_config; j < current.size; j++:
            previously_found/Status := current[j]
            if candidate.other_is_clearly_better previously_found --remaining_rounds=rem:
              dealt_with = true
              break
            if previously_found.other_is_clearly_better candidate --remaining_rounds=rem:
              current[j] = candidate
              dealt_with = true
              break
          if not dealt_with:
            current.add candidate
        else:
          // New position.
          index_of_best_of_each_tap_config = current.size
          current.add candidate
          current_opened = candidate.opened
          current_position = candidate.position

    current = current + [hall_of_fame]
    print
        highest_score current: it.pressure_released
    print
        (highest_scoring_element current: it.pressure_released).position_chain.join "\n"

  get_best current/Map:
    best := int.MIN
    best_overall_status/Status? := null
    current.do: | _ l/List |
      if l.size != 0:
        best_status := highest_scoring_element l: it.pressure_released
        if best_status.pressure_released > best:
          best = best_status.pressure_released
          best_overall_status = best_status
    return best_overall_status

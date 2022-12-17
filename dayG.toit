import host.file
import .aoc

class Status:
  pressure/int
  already_opened/int // mask
  remaining_pressure/int
  position_chain := []

  constructor.open --remaining_rounds/int prev/Status position/int pressure_at_position/int --names/Map:
    pressure_l := ?
    rem := ?
    ao := ?
    pc := ?
    if pressure_at_position != 0 and prev.already_opened & (1 << position) == 0:
      pressure_l = prev.pressure + pressure_at_position * (remaining_rounds - 1)
      rem = prev.remaining_pressure - pressure_at_position
      ao = prev.already_opened | (1 << position)
      pc = prev.position_chain + ["Opened valve at $names[position] releasing $pressure_at_position with $(remaining_rounds - 1) to go, giving $(pressure_l) in all"]
    else:
      pressure_l = prev.pressure
      rem = prev.remaining_pressure
      ao = prev.already_opened
      pc = prev.position_chain + ["Stayed at $names[position]"]
    pressure = pressure_l
    remaining_pressure = rem
    already_opened = ao
    position_chain = pc

  constructor.move prev/Status pos/int --names/Map:
    pressure = prev.pressure
    remaining_pressure = prev.remaining_pressure
    already_opened = prev.already_opened
    position_chain = prev.position_chain + ["Moved to $names[pos]"]
  
  constructor total_pressure/int:
    remaining_pressure = total_pressure
    pressure = 0
    already_opened = 0

  stringify: return "Pressure=$pressure/opened=$(%b already_opened)"

main:
  lines /List := (file.read_content "inputG.txt").to_string.trim.split "\n"
  valves := {:} // From name to bit position.
  names := {:}  // From bit position to name.
  flowrates := []
  dests := []
  total_pressure := 0
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

  run flowrates dests names --total_pressure=total_pressure --start=valves["AA"]

run flowrates/List dests/List names/Map --total_pressure/int --start/int:
  current := {start: [Status total_pressure]}
  30.repeat: | round |
    print "$round: $(sum current: current[it].size) candidates"
    //current.do: | pos list |
      //print "  $pos:"
      //list.do: print "    $it"
    next_gen := {:}
    rem := 30 - round
    current.do: | pos/int l/List |
      l.do: | status/Status |
        dests[pos].do: | dest/int |
          moved := Status.move status dest --names=names
          insert next_gen dest moved
        opened := Status.open --remaining_rounds=rem status --names=names pos flowrates[pos]
        insert next_gen pos opened
    // Remove those at each position that have opened the same tap, but are behind.
    next_gen.do: | pos/int l/List |
      l.sort --in_place: | a b |
        // Sort by which taps are open, secondarily by descending pressure.
        ao := b.already_opened - a.already_opened
        if ao != 0:
          ao
        else:
          b.pressure - a.pressure
      already := -1
      //print "Filtering:"
      next_gen[pos] = l.filter:
        if already == it.already_opened:
          //print "  Drop $it"
          false  // Only need the best of those with the same opened list.
        else:
          already = it.already_opened
          //print "  Keep $it"
          true

    current = next_gen
    best := (get_best current).pressure
    print "Best of next gen = $best"
    current.do: | pos/int l/List |
      current[pos] = l.filter: | status/Status |
        potential := status.remaining_pressure * rem
        status.pressure + potential >= best
        
  print (get_best current).pressure
  print
      (get_best current).position_chain.join "\n"

get_best current/Map:
  best := int.MIN
  best_overall_status/Status? := null
  current.do: | _ l/List |
    if l.size != 0:
      best_status := highest_scoring_element l --score=(: it.pressure)
      if best_status.pressure > best:
        best = best_status.pressure
        best_overall_status = best_status
  return best_overall_status

insert m/Map position/int candidate/Status:
  l/List := m.get position --init=: []
  l.add candidate
  return

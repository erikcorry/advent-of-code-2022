import host.file
import .aoc

class WorkRange:
  from /int := 0
  to /int := 0

  constructor range/string:
    split2 range "-" (:int.parse it): | f t |
      from = f
      to = t

  surrounds other/WorkRange -> bool:
    return from <= other.from <= other.to <= to

  overlaps_with other/WorkRange -> bool:
    return       from <= other.from <=       to or
           other.from <=       from <= other.to

main:
  lines := (file.read_content "input4.txt").to_string.trim.split "\n"
  print (count (lines.map: split2 it "," (: WorkRange it): | l r |
    (l.surrounds r) or (r.surrounds l)))
  print (count (lines.map: split2 it "," (: WorkRange it): | l r |
    l.overlaps_with r))

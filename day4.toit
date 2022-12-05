import host.file

class WorkRange:
  from /int
  to /int

  constructor range/string:
    hyphen := range.index_of "-"
    from = int.parse range[..hyphen]
    to   = int.parse range[hyphen + 1..]

  surrounds other/WorkRange -> bool:
    return from <= other.from <= other.to <= to

  overlaps_with other/WorkRange -> bool:
    return       from <= other.from <=       to or
           other.from <=       from <= other.to

main:
  embedded := 0
  overlap := 0
  (file.read_content "input4.txt").to_string.trim.split "\n": | line |
    elves /List := line.split ","            // Two-element list of strings of form "5-10".
    ranges /List := elves.map: WorkRange it  // Two-element list of WorkRange objects.
    if (ranges[0].surrounds ranges[1]) or (ranges[1].surrounds ranges[0]):
      embedded++
    if ranges[0].overlaps_with ranges[1]:
      overlap++

  print embedded
  print overlap

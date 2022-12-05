import host.file

main:
  part --one_at_a_time=true
  part --one_at_a_time=false

part --one_at_a_time/bool:
  // A list of lists.  Each element is a list of crates from bottom to top.
  stacks := []
  (file.read_content "input5.txt").to_string.trim.split "\n": | line |
    if line.contains "[":
      for i := 1; i < line.size; i += 4:
        letter := line[i]
        if 'A' <= letter <= 'Z':
          stack_number := (i / 4) + 1
          // Make sure the stack list is long enough.
          while stacks.size <= stack_number:
            stacks.add []
          // This is inefficient, but not called very often.
          stacks[stack_number] = [letter] + stacks[stack_number]
    else if line.starts_with "move":
      parts := line.split " "
      crate_count := int.parse parts[1]
      from := int.parse parts[3]
      to := int.parse parts[5]
      if one_at_a_time:
        crate_count.repeat:
          top := stacks[from].remove_last
          stacks[to].add top
      else:
        src := stacks[from]
        stacks[to] += src[src.size - crate_count..]
        stacks[from] = src[..src.size - crate_count]
  answer := ""
  stacks[1..].do: answer += "$(%c it.last)"
  print answer

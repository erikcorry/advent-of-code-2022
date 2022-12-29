import .resources

main:
  run 4
  run 14

run limit/int:
  line /string := INPUT6.trim
  mask := 0
  deque := Deque
  line.size.repeat: | i |
    index := line[i] - 'b'
    if i >= limit:
      first := deque.remove_first
      mask ^= 1 << first
    mask ^= 1 << index
    if mask.population_count == limit:
        print i + 1
        return
    deque.add index

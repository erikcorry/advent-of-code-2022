import .aoc
import .resources

DIRECTIONS := [[1, 0], [0, 1], [-1, 0], [0, -1]]

get_width lines/List -> int:
  longest := 0
  lines.do: |line|
    if line.size == 0: return longest
    longest = max longest line.size
  unreachable

get_height lines/List -> int:
  longest := 0
  lines.do: |line|
    if line.size == 0: return longest
    longest++
  unreachable

main:
  map := []
  lines /List := (INPUTM.trim --right).split "\n"
  WIDTH := get_width lines
  HEIGHT := get_height lines
  lines = lines.map: | line |
    pad := WIDTH - line.size
    if pad >= 0:
      line + (" " * (WIDTH - line.size))
    else:
      line

  posx := lines[0].index_of "."
  posy := 0
  direction := 0

  instructions := lines.last

  decode instructions --turn=(: | sign | direction = (direction + sign) & 3) --move=: | steps/int |
    dx := DIRECTIONS[direction][0]
    dy := DIRECTIONS[direction][1]
    if dx == 0:
      // Vertical.
      steps.repeat:
        next_y := wrap posy + dy HEIGHT
        while lines[next_y][posx] == ' ':
          next_y = wrap next_y + dy HEIGHT
        if lines[next_y][posx] == '.': posy = next_y
    else:
      // Horizontal.
      steps.repeat:
        next_x := wrap posx + dx WIDTH
        while lines[posy][next_x] == ' ':
          next_x = wrap next_x + dx WIDTH
        if lines[posy][next_x] == '.': posx = next_x

  print (posy + 1) * 1000 + (posx + 1) * 4 + direction

  posx = lines[0].index_of "."
  posy = 0
  direction = 0

  //  12
  //  3
  // 45
  // 6
  SQUARE := HEIGHT / 4  // Size of a square.
  decode instructions --turn=(: | sign | direction = (direction + sign) & 3) --move=: | steps/int |
    steps.repeat:
      dx := DIRECTIONS[direction][0]
      dy := DIRECTIONS[direction][1]
      next_x := posx + dx
      next_y := posy + dy
      next_direction := direction
      if dx == 0:
        // Vertical.
        if next_y == -1:
          if next_x < SQUARE * 2:
            // Went off top of square 1.  We come on to square 6 from the left.
            next_y = SQUARE * 2 + next_x
            next_x = 0
            next_direction = 0
          else:
            // Went off top of square 2.  We come on to square 6 from the bottom.
            next_x -= SQUARE * 2
            next_y = HEIGHT - 1
        else if next_y == HEIGHT:
          // Went off bottom of square 6.  We come on to square 2 from the top.
          next_x += SQUARE * 2
          next_y = 0
        else if lines[next_y][next_x] == ' ':
          if next_y == SQUARE:
            // Went off bottom of square 2.  We come on to square 3 from the right.
            next_y = next_x - SQUARE
            next_x = SQUARE * 2 - 1
            next_direction = 2
          else if next_y == SQUARE * 3:
            // Went off bottom of square 5.  We come on to square 6 from the right.
            next_y = SQUARE * 2 + next_x
            next_x = SQUARE - 1
            next_direction = 2
          else:
            // Went off top of square 4.  We come on to square 3 from the left.
            next_y = SQUARE + next_x
            next_x = SQUARE
            next_direction = 0
      else:
        // Horizontal.
        if next_x == WIDTH:
          // Went off right of square 2.  We come on to square 5 from the right.
          next_y = 3 * SQUARE - next_y - 1
          next_x = 2 * SQUARE - 1
          next_direction = 2
        else if next_x == -1:
          if next_y < 3 * SQUARE:
            // Went off left of square 4.  We come on to square 1 from the left.
            next_y = 3 * SQUARE - next_y - 1
            next_x = SQUARE
            next_direction = 0
          else:
            // Went off left of square 6.  We come on to square 1 from the top.
            next_x = next_y - 2 * SQUARE
            next_y = 0
            next_direction = 1
        else if lines[next_y][next_x] == ' ':
          if next_y < SQUARE:
            // Went off left of square 1.  We come on to square 4 from the left.
            next_y = 3 * SQUARE - next_y - 1
            next_x = 0
            next_direction = 0
          else if next_y < 2 * SQUARE:
            if dx < 0:
              // Went off left side of square 3.  We come on the top of square 4.
              next_x = next_y - SQUARE
              next_y = SQUARE * 2
              next_direction = 1
            else:
              // Went off right side of square 3.  We come on the bottom of square 2.
              next_x = next_y + SQUARE
              next_y = SQUARE - 1
              next_direction = 3
          else if next_y < 3 * SQUARE:
            // Went off the right side of square 5.  We come on the right of square 2.
            next_y = 3 * SQUARE - next_y - 1
            next_x = 3 * SQUARE - 1
            next_direction = 2
          else:
            // Went off the right side of square 6.  We come on the bottom of square 5.
            next_x = next_y - 2 * SQUARE
            next_y = 3 * SQUARE - 1
            next_direction = 3
      if lines[next_y][next_x] == '.':
        posx = next_x
        posy = next_y
        direction = next_direction

  print (posy + 1) * 1000 + (posx + 1) * 4 + direction

decode str/string [--turn] [--move]:
  for i := 0; i < str.size; :
    c := str[i]
    if c == 'R':
      turn.call 1
      i++
    else if c == 'L':
      turn.call -1
      i++
    else if c == ' ':
      i++
    else:
      j := i
      while j < str.size and '0' <= str[j] <= '9':
        j++
      move.call (int.parse str[i..j])
      i = j

wrap x width:
  if x == -1: return width - 1
  if x == width: return 0
  return x

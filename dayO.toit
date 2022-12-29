import .aoc
import .resources

class Bitmap:
  left /List
  right /List
  height /int
  half_width /int

  constructor width .height:
    half_width = width / 2
    left = List height: 0
    right = List height: 0

  pr left right up down possible:
    print "#" * (half_width * 2 + 2)
    height.repeat: | y |
      line := "#"
      (half_width * 2).repeat: | x |
        l := (left.get x y) ? 1 : 0
        r := (right.get x y) ? 1 : 0
        u := (up.get x y) ? 1 : 0
        d := (down.get x y) ? 1 : 0
        sum := l + r + u + d
        if sum == 0:
          if possible.get x y:
            line += "@"
          else:
            line += "."
        else if sum > 1:
          line += "$(%c '0' + sum)"
        else if l != 0:
          line += "<"
        else if r != 0:
          line += ">"
        else if u != 0:
          line += "^"
        else if d != 0:
          line += "v"
      print "$line#"
    print "#" * (half_width * 2 + 2)

  clear x/int y/int -> bool:
    return not get x y

  get x/int y/int -> bool:
    if x >= half_width:
      return (right[y] >> (x - half_width)) & 1 != 0
    return (left[y] >> x) & 1 != 0

  set x/int y/int -> none:
    if x >= half_width:
      right[y] |= 1 << (x - half_width)
    else:
      left[y] |= 1 << x

  shift_right -> none:
    height.repeat: | y |
      hi_r := (right[y] >> (half_width - 1)) & 1
      hi_l := (left[y] >> (half_width - 1)) & 1
      right[y] = (right[y] << 1) | hi_l
      left[y]  = (left[y]  << 1) | hi_r

  shift_left -> none:
    height.repeat: | y |
      hi_l := (left[y] & 1) << (half_width - 1)
      hi_r := (right[y] & 1) << (half_width - 1)
      left[y] = (left[y] >> 1) | hi_r
      right[y] = (right[y] >> 1) | hi_l

  shift_up -> none:
    top_r := right[0]
    top_l := left[0]
    (height - 1).repeat:
      right[it] = right[it + 1]
      left[it] = left[it + 1]
    right[height - 1] = top_r
    left[height - 1] = top_l

  shift_down -> none:
    top_r := right[height - 1]
    top_l := left[height - 1]
    for y := height - 2; y >= 0; y--:
      right[y + 1] = right[y]
      left[y + 1] = left[y]
    right[0] = top_r
    left[0] = top_l

  do [block] -> none:
    height.repeat: | y |
      half_width.repeat: | x |
        mask := 1 << x
        if left[y] & mask != 0:
          block.call x y
        if right[y] & mask != 0:
          block.call x+half_width y

DIRECTIONS_OR_STAY_STILL := [[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1]]

WIDTH := 0
HEIGHT := 0

main:
  lines /List := INPUTO.trim.split "\n"
  WIDTH = lines[0].size - 2
  HEIGHT = lines.size - 2
  left := Bitmap WIDTH HEIGHT
  right := Bitmap WIDTH HEIGHT
  down := Bitmap WIDTH HEIGHT
  up := Bitmap WIDTH HEIGHT
  HEIGHT.repeat: | y |
    WIDTH.repeat: | x |
      c := lines[y + 1][x + 1]
      if c == '<': left.set x y
      if c == '>': right.set x y
      if c == 'v': down.set x y
      if c == '^': up.set x y
  there := run left right up down 0 0 WIDTH - 1 HEIGHT - 1
  back := run left right up down WIDTH - 1 HEIGHT - 1 0 0
  again := run left right up down 0 0 WIDTH - 1 HEIGHT - 1
  print there
  print there + back + again

run left/Bitmap right/Bitmap up/Bitmap down/Bitmap start_x start_y end_x end_y -> int:
  possible := Bitmap WIDTH HEIGHT
  minute := 0
  while true:
    //left.pr left right up down possible
    minute++
    left.shift_left
    right.shift_right
    up.shift_up
    down.shift_down
    if possible.get end_x end_y:
      return minute
    next_possible := Bitmap WIDTH HEIGHT
    possible.do: | x y |
      DIRECTIONS_OR_STAY_STILL.do: | xy |
        nx := x + xy[0]
        ny := y + xy[1] 
        if 0 <= nx < WIDTH and 0 <= ny < HEIGHT:
          if (left.clear nx ny) and (right.clear nx ny) and (up.clear nx ny) and (down.clear nx ny):
            next_possible.set nx ny
    if (left.clear start_x start_y) and (right.clear start_x start_y) and (up.clear start_x start_y) and (down.clear start_x start_y):
      next_possible.set start_x start_y
    possible = next_possible

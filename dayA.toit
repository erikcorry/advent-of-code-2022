import host.file

main:
  HEIGHT := 6
  WIDTH := 40
  x := 1
  time := 0
  next_sample := 20
  total := 0
  crt := ByteArray HEIGHT * WIDTH: ' '

  (file.read_content "inputA.txt").to_string.trim.split "\n": | line |
    parts := line.split " "
    insn := parts[0]
    x_inc := ?
    t_inc := ?
    if insn == "noop":
      x_inc = 0
      t_inc = 1
    else if insn == "addx":
      x_inc = int.parse parts[1]
      t_inc = 2
    else:
      throw line

    t_inc.repeat:
      if (time % WIDTH - x).abs < 2: crt[time] = '#'
      time++
      if time == next_sample:
        total += next_sample * x
        next_sample += WIDTH

    x += x_inc

  print total
  List.chunk_up 0 crt.size WIDTH: | from to | print crt[from..to].to_string

import .aoc
import .resources

// First install the host package with `jag pkg install`.
// Run with `jag run -d host template.toit`

TR ::= {
    '0': 0,
    '1': 1,
    '2': 2,
    '-': -1,
    '=': -2,
}

CHARS := "=-012"

main:
  total :=
      sum (INPUTP.trim.split "\n"): | txt/string |
        l /List := List txt.size: TR[txt[it]]
        l.reduce: | t c | t * 5 + c
  base5 := total.stringify 5
  print base5
  l := List base5.size: base5[it] - '0'
  adjust := 0
  for i := l.size - 1; i >= 0; i--:
    value := l[i] + adjust
    adjust = 0
    while value < -2:
      value += 5
      adjust--
    while value > 2:
      value -= 5
      adjust++
    l[i] = CHARS[value + 2]
  if adjust != 0:
    l = [CHARS[adjust + 2]] + l
  ba := ByteArray l.size: l[it]
  print ba.to_string

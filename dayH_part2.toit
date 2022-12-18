// Every time we use ROCK_DIFF rocks we create HEIGHT_DIFF height difference
HEIGHT_DIFF ::= 2626
ROCK_DIFF   ::= 1720
SMALL_REPEATS ::= 2022
LARGE_REPEATS ::= 1_000_000_000_000

RESULT_3160 ::= 4820
RESULT_4880 ::= 7446    // 1720 rocks more gives 2626 height more.

main:
  m1 := SMALL_REPEATS % ROCK_DIFF
  m2 := LARGE_REPEATS % ROCK_DIFF

  size_to_run := SMALL_REPEATS - m1 + m2

  print "size_to_run=$size_to_run"
  print "size_to_run % ROCK_DIFF = $(size_to_run % ROCK_DIFF)"

  print "m1=$m1 m2=$m2"

  print "2*rock_diff + m2 = $(2 * ROCK_DIFF + m2)"

  print "modulus rest for large repeats = $(RESULT_3160 % HEIGHT_DIFF)"

  assert: (calculate 4880) == RESULT_4880
  print (calculate 1_000_000_000_000)


calculate repeats/int -> int:
  assert: repeats % ROCK_DIFF == 3160 % ROCK_DIFF
  return (repeats / ROCK_DIFF) * HEIGHT_DIFF + RESULT_3160 % HEIGHT_DIFF

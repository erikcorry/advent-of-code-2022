import .resources

SCORE_TABLE ::= {
  "A X": 4, "B X": 1, "C X": 7,
  "A Y": 8, "B Y": 5, "C Y": 2,
  "A Z": 3, "B Z": 9, "C Z": 6,
}

PLAY_TABLE ::= [
  [3, 1, 2],  // Lose.
  [1, 2, 3],  // Draw.
  [2, 3, 1],  // Win.
]

main:
  score := 0
  score2 := 0
  INPUT2.split "\n": | line |
    if line != "":
      // First half.
      score += SCORE_TABLE[line]
      // Second half.
      result := line[2] - 'X'  // 0, 1, or 2.
      score2 += 3 * result
      opponent := line[0] - 'A'
      score2 += PLAY_TABLE[result][opponent]

  print score
  print score2

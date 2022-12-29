import .aoc
import .resources

abstract class Observer:
  forest /Forest

  constructor .forest:

  // Return true to continue
  abstract observe x/int y/int -> bool

// For part 1 we count the trees that are higher than any encountered so far.
class VisibilitySearcher extends Observer:
  highest := -1

  constructor forest/Forest:
    super forest

  observe x/int y/int -> bool:
    here := forest.height x y
    if here > highest:
      forest.set_visible x y
      highest = here
    return here != '9'

// For part 2 we count the trees that are lower than the initial height, stopping when
// we find a tree that is at least as high as the initial height.
class ScoreEvaluator extends Observer:
  height /int
  score /int := 0

  constructor forest/Forest .height:
    super forest

  observe x/int y/int -> bool:
    score++
    tree_height := forest.height x y
    return tree_height < height

class Forest:
  rows /List := INPUT8.trim.split "\n"
  visible /List
  xmax /int
  ymax /int

  constructor:
    ymax = rows.size
    xmax = rows[0].size
    visible = List rows.size: List rows[0].size: false

  height x/int y/int -> int:
    return rows[y][x]

  set_visible x/int y/int -> none:
    visible[y][x] = true

  calculate_visible_trees -> none:
    ymax.repeat: | row |
      do_row row (VisibilitySearcher this) --direction=1
      do_row row (VisibilitySearcher this) --direction=-1
    xmax.repeat: | col |
      s := VisibilitySearcher this
      do_col col (VisibilitySearcher this) --direction=1
      do_col col (VisibilitySearcher this) --direction=-1
    print
        visible.reduce --initial=0: | total row |
          row.reduce --initial=total: | total2 is_visible |
            is_visible ? total2 + 1 : total2

  do_row row/int observer/Observer --direction/int --from/int=(direction == 1 ? 0 : ymax - 1):
    for x := from; x != -1 and x != xmax; x += direction:
      if not observer.observe x row: return

  do_col col/int observer/Observer --direction/int --from/int=(direction == 1 ? 0 : xmax - 1):
    for y := from; y != -1 and y != ymax; y += direction:
      if not observer.observe col y: return

  evaluate_score x/int y/int -> int:
    h := height x y
    north := ScoreEvaluator this h
    do_col x north --from=(y - 1) --direction=-1
    east := ScoreEvaluator this h
    do_row y east --from=(x + 1) --direction=1
    south := ScoreEvaluator this h
    do_col x south --from=(y + 1) --direction=1
    west := ScoreEvaluator this h
    do_row y west --from=(x - 1) --direction=-1
    return north.score * east.score * south.score * west.score

  find_best_score:
    best := -1
    ymax.repeat: | y |
      xmax.repeat: | x |
        best = max best (evaluate_score x y)
    print best

main:
  forest := Forest
  forest.calculate_visible_trees
  forest.find_best_score

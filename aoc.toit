// Copyright (C) 2022 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

/// Useful functions and classes for solving puzzle programming tasks.

class Coord:
  x /int
  y /int

  constructor .x .y:

  hash_code :
    return x * 1237 + y * 7

  operator == other/Coord -> bool:
    return other.x == x and other.y == y

/**
Calculates the reduction of the return values from the block.
The block is called with the reduction so far, the next non-null element (and
  the index for those collections where that makes sense).
Unlike collection.reduce this works on string and byte arrays, skips null
  entries, and passes the index to the block.
*/
reduce collection --initial [block]:
  result := initial
  if collection is List or collection is ByteArray or collection is string:
    indexable := collection as any
    for i := 0; i < indexable.size; i++:
      element := indexable[i]
      if element: result = block.call result element i
  else:
    index := 0
    collection.do:
      if it: result = block.call result it index
      index++
  return result

/**
Calculates the sum of non-null elements in the collection.
*/
sum collection:
  return reduce collection --initial=0: | total n | total + n

/**
Calculates the sum of the return values from the block.
The block is called with each non-null element (and the index for those collections
  where that makes sense).
*/
sum collection [block]:
  return reduce collection --initial=0: | total element index | total + (block.call element index)

/**
Calculates the product of non-null elements in the collection.
*/
product collection:
  return reduce collection --initial=1: | total n | total * n

/**
Calculates the product of the return values from the block.
The block is called with each non-null element (and the index for those collections
  where that makes sense).
*/
product collection [block]:
  return reduce collection --initial=1: | total element index | total * (block.call element index)

/**
Calculates the bitwise-and of non-null elements in the collection.
*/
bitand collection:
  return reduce collection --initial=-1: | total n | total & n

/**
Calculates the bitwise-and of the return values from the block.
The block is called with each non-null element (and the index for those collections
  where that makes sense).
*/
bitand collection [block]:
  return reduce collection --initial=-1: | total element index | total & (block.call element index)

/**
Calculates the bitwise-or of non-null elements in the collection.
*/
bitor collection:
  return reduce collection --initial=0: | total n | (total | n)

/**
Calculates the bitwise-or of the return values from the block.
The block is called with each non-null element (and the index for those collections
  where that makes sense).
*/
bitor collection [block]:
  return reduce collection --initial=0: | total element index | (total | (block.call element index))

/**
Calculates the bitwise-xor of non-null elements in the collection.
*/
bitxor collection:
  return reduce collection --initial=0: | total n | total ^ n

/**
Calculates the bitwise-or of the return values from the block.
The block is called with each non-null element (and the index for those collections
  where that makes sense).
*/
bitxor collection [block]:
  return reduce collection --initial=0: | total element index | total ^ (block.call element index)

/**
Calculates the number of truthy things in the collection.
*/
count collection:
  return count collection: it

/**
Calculates the number of times the block returns truthiness when called with
  the elements of the collection.
The block is called with each element (and the index for those collections
  where that makes sense).
*/
count collection [block]:
  total := 0
  if collection is List or collection is ByteArray or collection is string:
    indexable := collection as any
    for i := 0; i < indexable.size; i++:
      element := indexable[i]
      if (block.call element i): total++
  else:
    index := 0
    collection.do: | element |
      if (block.call element index): total++
    index++
  return total

to_list string_or_byte_array -> List:
  return List string_or_byte_array.size: string_or_byte_array[it]

/// Split into two, call block with left and right.
split2 str/string divider/string [block]:
  return split2 str divider (: it) block

/// Split into two, map with mapping block, call block with left and right.
split2 str/string divider/string [mapping_block] [block]:
  return split2 str divider mapping_block mapping_block block

/// Split into two, map with mapping blocks, call block with left and right.
split2 str/string divider/string [left_mapping_block] [right_mapping_block] [block]:
  index := str.index_of divider
  if index < -1: throw "Did not find '$divider' in '$str'"
  return block.call (left_mapping_block.call str[..index]) (right_mapping_block.call str[index + divider.size..])

/// Split into three, call block with left, center, right.
split3 str/string divider1/string divider2/string=divider1 [block]:
  return split3 str divider1 divider2 (: it) block

/// Split into three, map with mapping block, call block with left, center, right.
split3 str/string divider1/string divider2/string=divider1 [mapping_block] [block]:
  return split3 str divider1 divider2 mapping_block mapping_block mapping_block block

/// Split into three, map with three mapping blocks, call block with left, center, right.
split3 str/string divider1/string divider2/string=divider1 [left_mapping_block] [center_mapping_block] [right_mapping_block] [block]:
  split2 str divider1: | first rest |
    split2 rest divider2: | second third |
      return block.call
        left_mapping_block.call first
        center_mapping_block.call second
        right_mapping_block.call third
  unreachable

/// Split into four, call block with four arguments
split4 str/string divider1/string divider2/string=divider1 divider3/string=divider2 [block]:
  return split4 str divider1 divider2 divider3 (: it) block

/// Split into four, map with mapping block, call block with four arguments
split4 str/string divider1/string divider2/string=divider1 divider3/string=divider2 [mapping_block] [block]:
  split2 str divider1: | first rest |
    split3 rest divider2 divider3: | second third fourth |
      return block.call
        mapping_block.call first
        mapping_block.call second
        mapping_block.call third
        mapping_block.call fourth
  unreachable

/// Split into five, call block with five arguments
split5 str/string divider1/string divider2/string=divider1 divider3/string=divider2 divider4/string=divider3 [block]:
  return split5 str divider1 divider2 divider3 divider4 (: it) block

/// Split into five map with mapping block, call block with five arguments
split5 str/string divider1/string divider2/string=divider1 divider3/string=divider2 divider4/string=divider3 [mapping_block] [block]:
  split2 str divider1: | first rest |
    split4 rest divider2 divider3 divider4: | second third fourth fifth |
      return block.call
        mapping_block.call first
        mapping_block.call second
        mapping_block.call third
        mapping_block.call fourth
        mapping_block.call fifth
  unreachable

/// Split into six map with mapping block, call block with six arguments
split6 str/string divider1/string divider2/string=divider1 divider3/string=divider2 divider4/string=divider3 divider5/string=divider4 [block]:
  return split6 str divider1 divider2 divider3 divider4 divider5 (: it) block

/// Split into six map with mapping block, call block with six arguments
split6 str/string divider1/string divider2/string=divider1 divider3/string=divider2 divider4/string=divider3 divider5/string=divider4 [mapping_block] [block]:
  split2 str divider1: | first rest |
    split5 rest divider2 divider3 divider4 divider5: | second third fourth fifth sixth |
      return block.call
        mapping_block.call first
        mapping_block.call second
        mapping_block.call third
        mapping_block.call fourth
        mapping_block.call fifth
        mapping_block.call sixth
  unreachable

/// Split into up to n, call block with n arguments, some may be null.
split_up_to n/int str/string divider/string [block]:
  return split_up_to n str divider (: it) block

/// Split into up to n, map with mapping block, call block with n
/// arguments, some may be null.
split_up_to n/int str/string divider/string [mapping_block] [block]:
  list := str.split divider
  if list.size > n:
    tail := list[n - 1..].join divider
    list = list[0..n - 1].copy
    list.add tail
  while list.size < 6: list.add null
  return block.call
      list[0] == null ? null : (mapping_block.call list[0])
      list[1] == null ? null : (mapping_block.call list[1])
      list[2] == null ? null : (mapping_block.call list[2])
      list[3] == null ? null : (mapping_block.call list[3])
      list[4] == null ? null : (mapping_block.call list[4])
      list[5] == null ? null : (mapping_block.call list[5])

// Returns a list of n-element lists.
group n/int list/List -> List:
  return List list.size / n: list[it * n..(it + 1) * n]

// Calls block with pairs of elements, returns list of the results.
group2 list/List [mapping_block] -> List:
  return List list.size / 2: mapping_block.call list[it * 2] list[it * 2 + 1]

// Calls block with triples of elements, returns list of the results.
group3 list/List [mapping_block] -> List:
  return List list.size / 3: mapping_block.call list[it * 3] list[it * 3 + 1] list[it * 3 + 2]

// Highest number in a collection.
highest_number collection/Collection:
  return best collection --initial=-float.INFINITY --compare=(: | a b | b > a) --score=(: it): | score index element | return score

// Lowest number in a collection.
lowest_number collection/Collection:
  return best collection --initial=float.INFINITY --compare=(: | a b | b < a) --score=(: it): | score index element | return score

// Highest score in a collection using the block to evaluate elements.
highest_score collection/Collection [score]:
  return best collection --initial=-float.INFINITY --compare=(: | a b | b > a) --score=score: | score index element | return score

// Lowest score in a collection using the block to evaluate elements.
lowest_score collection/Collection [score]:
  return best collection --initial=float.INFINITY --compare=(: | a b | b < a) --score=score: | score index element | return score

// Highest scoring index in a list using the score block to evaluate elements.
highest_scoring_index list/List [--score]:
  return best list --initial=-float.INFINITY --compare=(: | a b | b > a) --score=score: | score index element | return index

// Lowest scoring index in a list using the score block to evaluate elements.
lowest_scoring_index list/List [--score]:
  return best list --initial=float.INFINITY --compare=(: | a b | b < a) --score=score: | score index element | return index

// Highest scoring element in a collection using the score block to evaluate elements.
highest_scoring_element collection/Collection [--score]:
  return best collection --initial=-float.INFINITY --compare=(: | a b | b > a) --score=score: | score index element | return element

// Lowest scoring element in a collection using the score block to evaluate elements.
lowest_scoring_element collection/Collection [--score]:
  return best collection --initial=float.INFINITY --compare=(: | a b | b < a) --score=score: | score index element | return element

/**
Find the best element in a collection.
Each non-null element is converted using the score block.
The compare block is used to find the best score so far.  The compare block
  should return true if the second argument is a better score than the first
  argument.
Returns the best score.
*/
best_score collection/Collection --initial [--compare] [--score]:
  return best collection --initial=initial --compare=compare --score=score: | score index element | return score

/**
Find the best element in a list.
Each non-null element is converted using the score block.
The compare block is used to find the best score so far.  The compare block
  should return true if the second argument is a better score than the first
  argument.
Returns the best index (for equally scoring elements, returns the index of the first).
*/
best_index list/List --initial [--compare] [--score]:
  return best list --initial=initial --compare=compare --score=score: | score index element | return index

/**
Find the best element in a collection.
Each non-null element is converted using the score block.
The compare block is used to find the best score so far.  The compare block
  should return true if the second argument is a better score than the first
  argument.
Returns the best element (for equally scoring elements, returns the first).
*/
best_element collection/Collection --initial [--compare] [--score]:
  return best collection --initial=initial --compare=compare --score=score: | score index element | return element

/**
Find the best element in a collection.
Each non-null element is converted using the score block.
The compare block is used to find the best score so far.  The compare block
  should return true if the second argument is a better score than the first
  argument.
Eventually the result block is called with three arguments:  The best score,
  the index of the best object, and the best object itself.
*/
best collection/Collection --initial [--compare] [--score] [result_block]:
  so_far := initial
  best_index := -1
  best_object := null
  if collection is List or collection is ByteArray or collection is string:
    indexable := collection as any
    for i := 0; i < indexable.size; i++:
      if indexable[i] != null:
        current_score := score.call indexable[i]
        if compare.call so_far current_score:
          so_far = current_score
          best_index = i
          best_object = indexable[i]
  else:
    index := 0
    collection.do: | element |
      if element != null:
        current_score := score.call element
        if compare.call so_far current_score:
          so_far = current_score
          best_index = index
          best_object = element
      index++
  return result_block.call so_far best_index best_object

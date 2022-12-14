import .aoc
import .resources

class Lexer:
  pos := 0
  str /string

  constructor .str:

  peek -> int: return str[pos]
  peek_is_number -> bool: return '0' <= str[pos] <= '9'

  get -> any:
    assert: peek_is_number
    i := pos
    while peek_is_number: pos++
    return int.parse str[i..pos]

  discard -> none:
    pos++

interface Thyng:
  // Return negative number if this is less than other.
  cmp other/Thyng -> int

  static cmp a/string b/string -> int:
    a_thing := Thyng (Lexer a)
    b_thing := Thyng (Lexer b)
    return a_thing.cmp b_thing

  constructor lexer/Lexer:
    if lexer.peek == '[':
      list := []
      lexer.discard
      while true:
        if lexer.peek == ']': break
        if lexer.peek == ',': lexer.discard
        list.add (Thyng lexer)
      lexer.discard
      return Lyst list
    if lexer.peek_is_number:
      return Ynt (lexer.get)
    unreachable

class Lyst implements Thyng:
  list /List

  size -> int: return list.size

  operator [] index/int -> Thyng: return list[index]

  constructor .list:

  operator == other/Thyng:
    if other is Ynt: return false
    l := other as Lyst
    if size != l.size: return false
    for i := 0; i < size; i++:
      if list[i] != l[i]: return false
    return true

  cmp other -> int:
    if other is Ynt:
      return -(other.cmp this)
    l := other as Lyst
    for i := 0; i < size; i++:
      if i >= l.size: return 1
      c := list[i].cmp l[i]
      if c != 0: return c
    if size == l.size: return 0
    return -1

class Ynt implements Thyng:
  value /int

  constructor .value:

  operator == other/Thyng:
    if other is Lyst: return false
    return value == (other as Ynt).value

  cmp other/Thyng -> int:
    if other is Ynt:
      return value - (other as Ynt).value
    else:
      // Comparing int to list.  We convert the int to a short list and compare those.
      temp := Lyst [Ynt value]
      return temp.cmp other

main:
  pairs /List := INPUTD.trim.split "\n\n"
  sum := 0
  list := []
  for i := 0; i < pairs.size; i++:
    lr := pairs[i].split "\n"
    // Originally we parsed the strings here and created Thyng
    // instances (either Lyst or Ynt).  That takes too much memory
    // on an ESP32, so instead we just store the strings.  When we
    // need to compare them with each other (eg. below for the sort)
    // we can reify the objects by parsing the strings on demand.
    left := lr[0]
    right := lr[1]
    list.add left
    list.add right
    if (Thyng.cmp left right) < 0:
      sum += i + 1
  print sum

  two := "[[2]]"
  six := "[[6]]"
  list.add two
  list.add six

  list.sort --in_place: | a b | Thyng.cmp a b

  print
      product list: | thyng/string index/int |
        if thyng == two or thyng == six:
          index + 1
        else:
          1

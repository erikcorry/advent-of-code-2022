import .aoc
import .resources

/// Solution for Day 7 of Advent of Code 2022.
/// See https://adventofcode.com/2022/day/7

abstract class FileOrDir:
  abstract size -> int

class File extends FileOrDir:
  size /int

  constructor .size:

class Dir extends FileOrDir:
  entries_ /Map := {:}
  parent /Dir?
  size_ /int? := null

  constructor --.parent=null:

  add name/string object/FileOrDir -> none:
    entries_[name] = object

  lookup name/string -> FileOrDir:
    return entries_[name]

  size -> int:
    if size_: return size_
    total := 0
    entries_.do: | _ file_or_dir/FileOrDir |
      total += file_or_dir.size
    size_ = total
    return total

  find [block]:
    entries_.do: | name/string file_or_dir/FileOrDir |
      block.call name file_or_dir
      if file_or_dir is Dir:
        dir := file_or_dir as Dir
        dir.find block

populate -> Dir:
  root := Dir
  cwd := root
  INPUT7.trim.split "\n": | line/string |
    split2 line " ": | left right |
      if left == "\$":
        split_up_to 2 right " ": | exe arg |
          if exe == "cd":
            if arg == "..":
              cwd = cwd.parent
            else if arg == "/":
              cwd = root
            else:
              cwd = (cwd.lookup arg) as Dir
      else if left == "dir":
        cwd.add
            right
            (Dir --parent=cwd)
      else:
        size := int.parse left
        cwd.add
            right
            File size
  return root

main:
  root := populate

  SMALL_DIR_LIMIT := 100_000

  dirs := []
  root.find: | _ file_or_dir/FileOrDir |
    if file_or_dir is Dir:
      dirs.add file_or_dir

  print
      sum (dirs.filter: it.size < SMALL_DIR_LIMIT): it.size

  TOTAL  ::= 70_000_000
  NEEDED := 30_000_000
  must_free := NEEDED + root.size - TOTAL

  print
      lowest_score dirs: | dir | dir.size > must_free ? dir.size : int.MAX

import host.file

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
  (file.read_content "input7.txt").to_string.trim.split "\n": | line/string |
    if line.starts_with "\$ ":
      command := line[2..]
      if command.starts_with "cd ":
        dirname := command[3..]
        if dirname == "..":
          cwd = cwd.parent
        else if dirname == "/":
          cwd = root
        else:
          cwd = (cwd.lookup dirname) as Dir
    else:
      if line.starts_with "dir ":
        cwd.add
            line[4..]
            (Dir --parent=cwd)
      else:
        idx := line.index_of " "
        size := int.parse line[..idx]
        name := line[idx + 1..]
        cwd.add
            name
            File size
  return root

main:
  root := populate

  SMALL_DIR_LIMIT := 100_000

  small_dirs_total := 0
  root.find: | name/string file_or_dir/FileOrDir |
    if file_or_dir is Dir:
      if file_or_dir.size <= SMALL_DIR_LIMIT:
        small_dirs_total += file_or_dir.size
  print small_dirs_total

  TOTAL  ::= 70_000_000
  NEEDED := 30_000_000
  must_free := NEEDED + root.size - TOTAL

  best := null
  root.find: | name/string file_or_dir/FileOrDir |
    if file_or_dir is Dir:
      if file_or_dir.size > must_free:
        if best == null or file_or_dir.size < best.size:
          best = file_or_dir
  print best.size

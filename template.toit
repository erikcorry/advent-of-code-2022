// Template answer that shows how to read an input file into a list of
// lines.

import host.file

// First install the host package with `jag pkg install`.
// Run with `jag run -d host template.toit`

main:
  lines /List := (file.read_content "inputx.txt").to_string.trim.split "\n"
  // Do the magic on the lines.  You may want to use `int.parse` to convert
  // strings to integers.

  print "Answer: There were $lines.size lines."

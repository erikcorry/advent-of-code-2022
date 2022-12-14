import host.file
import .aoc

// First install the host package with `jag pkg install`.
// Run with `jag run -d host template.toit`

main:
  lines /List := (file.read_content "inputx.txt").to_string.trim.split "\n"

  print "Answer: There were $lines.size lines."

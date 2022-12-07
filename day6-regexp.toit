import host.file
import regexp show RegExp

/// A sick, sick solution to day 6 of Advent of Code.  This is very slow,
/// partly because it's a terrible way to solve the puzzle, partly because
/// the regexp package is not optimized in any way.

/// Requires the experimental regexp package.  Check out
/// https://github.com/erikcorry/toit-dartino-regexp, then use
/// jag pkg install --local ../toit-dartino-regexp/  --name=regexp

main:
  run 4
  run 14

run limit/int:
  line /string := (file.read_content "input6.txt").to_string.trim
  // No raw strings, so backslashes and dollar signs must be
  // escaped with more backslashes.
  re := RegExp "(?=.{$limit}(.*\$))(?!.{0,$limit}?(.).{0,$limit}\\2.{0,$limit}\\1)"
  match := re.first_matching line
  print match.index + limit

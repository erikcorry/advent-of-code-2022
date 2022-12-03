import host.file

main:
  sum "\x04\x01\a\b\x05\x02\x03\t\x06"
  sum "\x03\x01\x02\x04\x05\x06\b\t\a"

sum table:
  print (((file.read_content "input2.txt").to_string.trim.split "\n").reduce --initial=0: | sum line | sum + table[line[2] * 3 + line[0] - 329])

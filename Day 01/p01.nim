import std/[strutils, sugar, tables]

const
  Digits1 = collect(for i in 0..9: {$i: i})
  Digits2 = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
             "six": 6, "seven": 7, "eight": 8, "nine": 9}.toTable

proc lineValue(line: string; digits: Table[string, int]): int =
  ## Compute the "value" of a line using the given digit table.
  var minpos = line.len
  var maxpos = -1
  var first, last: int
  for s, val in digits:
    let pos1 = line.find(s)
    if pos1 >= 0 and pos1 < minpos:
      first = val
      minpos = pos1
    let pos2 = line.rfind(s)
    if pos2 >= 0 and pos2 > maxpos:
      last = val
      maxpos = pos2
  result = 10 * first + last


### Part 1 ###

var sum = 0
for line in lines("p01.data"):
  sum += line.lineValue(Digits1)
echo "Part 1: ", sum


### Part 2 ###

# Prepare the digits table.
var digits = Digits1
for s, val in Digits2:
  digits[s] = val

sum = 0
for line in lines("p01.data"):
  sum += line.lineValue(digits)
echo "Part 2: ", sum

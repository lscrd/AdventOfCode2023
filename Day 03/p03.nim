import std/[strutils, tables]

type
  Position = tuple[row, col: int]
  # Description of a number.
  Number = tuple[val, row, firstCol, lastCol: int]


iterator ajdacentPos(number: Number): tuple[row, col: int] =
  ## Yield the positions adjacent to given the given number.
  ## We don't care if the position is invalid.
  let firstCol = number.firstCol - 1
  let lastCol = number.lastCol + 1
  var row = number.row - 1
  for col in firstCol..lastCol:
    yield (row, col)
  inc row
  yield (row, firstCol)
  yield (row, lastCol)
  inc row
  for col in firstCol..lastCol:
    yield (row, col)


# Parse data and build structures needed for processing.
var numbers: seq[Number]            # List of numbers.
var symbols: Table[Position, char]  # Mapping of symbol positions to symbol values.
var row = -1
for line in lines("p03.data"):
  if line.len == 0: continue
  let line = line & '.'   # Add a sentinel to simplify code.
  inc row
  var firstCol = -1
  var lastCol = -1
  var val = 0
  for col, c in line:
    if c in Digits:
      if firstCol < 0: firstCol = col
      lastCol = col
      val = 10 * val + ord(c) - ord('0')
    else:
      if firstCol >= 0:
        # End of a number.
        numbers.add (val, row, firstCol, lastCol)
        firstCol = -1
        val = 0
      if c != '.':
        symbols[(row, col)] = c


### Part 1 ###

var partNumberSum = 0
var partValues: Table[Position, seq[int]]   # Mapping of star positions to lists of part numbers.
for number in numbers:
  var isPart = false
  for pos in ajdacentPos(number):
    if pos in symbols:
      isPart = true
      if symbols[pos] == '*':
        partValues.mgetOrPut(pos, @[]).add number.val
  if isPart:
    partNumberSum += number.val
echo "Part 1: ", partNumberSum


### Part 2 ###

var gearRatioSum = 0
for vals in partValues.values:
  if vals.len == 2:
    # Found a gear. Add the gear ratio.
    gearRatioSum += vals[0] * vals[1]
echo "Part 2: ", gearRatioSum

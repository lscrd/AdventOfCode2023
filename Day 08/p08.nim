import std/[math, strscans, strutils, tables]

type
  Direction = 0..1                    # Used as index in left/right instructions string.
  Id = string                         # Node ID.
  Network = Table[Id, array[2, Id]]   # Mapping ID -> (left ID, right ID).


iterator directions(leftRight: string): Direction =
  ## Yields the directions to use.
  while true:
    for dirChar in leftRight:
      yield ord(dirChar == 'R')   # L = 0, R = 1

# Read left/right instructions string.
let data = readFile("p08.data").splitLines()
let leftRight = data[0]

# Build network table.
var network: Network
for line in data[1..^1]:
  var id, left, right: Id
  if line.scanf("$+ = ($+, $+)$.", id, left, right):
    network[id] = [left, right]


### Part 1 ###

var pos = "AAA"
var steps = 0
for dir in directions(leftRight):
  inc steps
  pos = network[pos][dir]
  if pos == "ZZZ": break

echo "Part 1: ", steps


### Part 2 ###

# Solving part 2 in the general case would be complicated but actual data makes
# things a lot easier.
# When starting from a node with ID ending with 'A', we find a node with ID ending
# with 'Z' after "n" steps. If we continue, the next node will be the same after
# exactly "n" steps.
# That means that, for each starting node, the successive positions will be the
# same after a given number of steps which is equal to the first number of steps.
# Let's call this number of steps the "cycle number".
# Then, the minimal number of steps needed to get all nodes ID ending with 'Z'
# is the least common multiple of the cycle numbers.

# Find the cycle numbers.
var cycleNums: seq[int]
for id in network.keys:
  if id.endsWith('A'):  # Starting node?
    var pos = id
    var steps = 0
    for dir in directions(leftRight):
      inc steps
      pos = network[pos][dir]
      if pos.endsWith('Z'): break
    cycleNums.add steps

# Compute the LCM of the cycle
var result = 1
for num in cycleNums:
  result = lcm(result, num)

echo "Part 2: ", result

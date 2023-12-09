import std/[sequtils, strutils]

type List = seq[int]

proc expand(list: List): tuple[left, right: seq[int]] =
  ## Return the first and last values of the successive
  ## differences as two lists of integers.
  var n = list.high
  var lastList = list
  while true:
    result[0].add lastList[0]
    result[1].add lastList[^1]
    var newList: List
    for i in 1..n:
      newList.add lastList[i] - lastList[i - 1]
    if allIt(newList, it == 0): break
    lastList = move(newList)
    dec n

proc extrapolateRight(values: seq[int]): int =
  ## Using the given values, compute the successive
  ## extrapolations on the right and return the last one.
  for i in countdown(values.len - 1, 0):
    result += values[i]

proc extrapolateLeft(values: seq[int]): int =
  ## Using the given values, compute the successive
  ## extrapolations on the left and return the last one.
  for i in countdown(values.len - 1, 0):
    result = values[i] - result

var result1, result2 = 0
for line in lines("p09.data"):
  if line.len == 0: continue
  let values = map(line.splitWhitespace(), parseInt).expand
  result1 += values[1].extrapolateRight
  result2 += values[0].extrapolateLeft

echo "Part 1: ", result1

echo "Part 2: ", result2

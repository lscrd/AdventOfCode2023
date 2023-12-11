import std/strutils

type Position = tuple[row, col: int]


func length(p1, p2: Position): int =
  ## Return the length of the shortest path between two positions.
  abs(p2.row - p1.row) + abs(p2.col - p1.col)


func addEmptyRows(positions: var seq[Position]; emptyRows: seq[int]; dist: int) =
  ## Update positions when adding empty rows.
  for i in countdown(emptyRows.high, 0):
    let row = emptyRows[i]
    for pos in positions.mitems:
      if pos.row > row:
        inc pos.row, dist


func addEmptyCols(positions: var seq[Position]; emptyCols: seq[int]; dist: int) =
  ## Update positions when adding empty columns.
  for i in countdown(emptyCols.high, 0):
    let col = emptyCols[i]
    for pos in positions.mitems:
      if pos.col > col:
        inc pos.col, dist


func lengthSum(positions: seq[Position]; emptyRows, emptyCols: seq[int]; incr: int): int =
  ## Return the sum of lengths of shortest paths between updated positions using given increment.

  # Build the list of updated positions.
  var positions = positions
  positions.addEmptyRows(emptyRows, incr)
  positions.addEmptyCols(emptyCols, incr)

  # Compute the sum of lengths.
  for i in 0..(positions.len - 2):
    for j in (i + 1)..positions.high:
      result += length(positions[i], positions[j])


# Read the image.
var image: seq[string]
for line in lines("p11.data"):
  if line.len != 0:
    image.add line

# Build the list of positions.
var positions: seq[Position]
for r, row in image:
  for c, val in row:
    if val == '#':
      positions.add (r, c)

# Find the empty rows.
var emptyRows: seq[int]
for r, row in image:
  if row.find('#') < 0:
    emptyRows.add r

# Find the empty columns.
var emptyCols: seq[int]
for c in 0..image[0].high:
  block Empty:
    for r in 0..image.high:
      if image[r][c] == '#':
        break Empty
    emptyCols.add c


### Part 1 ###
echo "Part 1: ", positions.lengthSum(emptyRows, emptyCols, 1)


### Part 2 ###
echo "Part 2: ", positions.lengthSum(emptyRows, emptyCols, 1_000_000 - 1)

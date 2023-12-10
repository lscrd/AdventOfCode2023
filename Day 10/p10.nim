import std/[sequtils, strutils, tables]

type
  Grid = seq[string]
  Distances = seq[seq[int]]
  Position = tuple[row, col: int]

const NotConnected = -1

# Indexing functions.
func `[]`(grid: Grid; pos: Position): char =
  grid[pos.row][pos.col]

func `[]=`(grid: var Grid; pos: Position; val: char) =
  grid[pos.row][pos.col] = val

func `[]`(dist: Distances; pos: Position): int =
  dist[pos.row][pos.col]

func `[]=`(dist: var Distances; pos: Position; val: int) =
  dist[pos.row][pos.col] = val

iterator neighbors(grid: Grid; pos: Position): Position =
  ## Yield the neighbors of a position.
  if pos.row > 0: yield (pos.row - 1, pos.col)
  if pos.col > 0: yield (pos.row, pos.col - 1)
  if pos.col < grid[0].high: yield (pos.row, pos.col + 1)
  if pos.row < grid.high: yield (pos.row + 1, pos.col)

func isConnected(grid: Grid; pos1, pos2: Position): bool =
  ## Return true if "pos1" and "pos2" are connected.
  let(pos1, pos2) = if pos1 < pos2: (pos1, pos2) else: (pos2, pos1)
  let c1 = grid[pos1]
  let c2 = grid[pos2]
  result = case c1:
           of 'F', 'S': c2 in {'|', 'J', 'L', 'S'} and pos2.row > pos1.row or
                        c2 in {'-', '7', 'J', 'S'} and pos2.col > pos1.col
           of '|', '7': c2 in {'|', 'J', 'L', 'S'} and pos2.row > pos1.row
           of 'L', '-': c2 in {'-', '7', 'J', 'S'} and pos2.col > pos1.col
           else: false

## Read the grid.
var grid: Grid
var row = 0
var startPos: Position
for line in lines("p10.data"):
  if line.len != 0:
    grid.add line
    let col = line.find('S')
    if col >= 0: startPos = (row, col)
    inc row


### Part 1 ###

var distances: Distances = newSeqWith(grid.len, repeat(-1, grid[0].len))
distances[startPos] = 0
var dist = 0                  # Current distance.
var positions = @[startPos]   # Current positions at current distance.
while positions.len > 0:
  var newPositions: seq[Position]   # Next positions to process.
  inc dist
  for pos in positions:
    for nextPos in grid.neighbors(pos):
      if distances[nextPos] == NotConnected:
        # Not yet processed.
        if grid.isConnected(pos, nextPos):
          distances[nextPos] = dist
          newPositions.add nextPos
  positions = move(newPositions)

echo "Part 1: ", dist - 1


### Part 2 ###

# Table used to find the character to use for starting point.
# The key is a tuple of deltas of the positions of the two connected points.
const StartChars = {((-1,  0), (0, -1)): 'J', ((-1,  0), (0, 1)): 'L',
                    ((-1,  0), (1,  0)): '|', (( 0, -1), (0, 1)): '-',
                    (( 0, -1), (1,  0)): '7', (( 0,  1), (1, 0)): 'F'}.toTable

# To find the enclosed points, we use a finite-state automaton.
# "s0" means that we are outside of the loop, "s1" means that we are
# inside the loop, "s2" means that we are on the frontier and the lower
# side is inside the loop, "s3" means that we are on the frontier and
# the upper side is inside the loop.
type State = enum s0, s1, s2, s3

# Automaton transition table.
const Transitions = {(s0, '|'): s1, (s0, 'F'): s2, (s0, 'L'): s3, (s0, '.'): s0,
                     (s1, '.'): s1, (s1, 'F'): s3, (s1, 'L'): s2, (s1, '|'): s0,
                     (s2, '-'): s2, (s2, 'J'): s1, (s2, '7'): s0,
                     (s3, '-'): s3, (s3, 'J'): s0, (s3, '7'): s1}.toTable

# Replace the 'S' of starting point with the right character.
var posDeltas: seq[(int, int)]
for pos in grid.neighbors(startPos):
  if distances[pos] == 1:
    posDeltas.add ((pos.row - startPos.row, pos.col - startPos.col))
grid[startPos] = StartChars[(posDeltas[0], posDeltas[1])]

# Replace the characters of non-connected points with a '.'.
for r, row in distances:
  for c, dist in row:
    if dist == NotConnected:
      grid[r][c] = '.'

# Process by rows.
var count = 0
for row in grid:
  var state = s0
  for ch in row:
    let newState = Transitions[(state, ch)]
    if state == s1 and newState == s1:
      inc count
    state = newState

echo "Part 2: ", count

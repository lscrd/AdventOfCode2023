import std/[strscans, strutils]

type
  Color {.pure.} = enum Red = "red", Green = "green", Blue = "blue"
  CubeSet = array[Color, int]
  Game = ref object
    id: int
    sets: seq[CubeSet]

proc newGame(line: string): Game =
  ## Parse a game line and return a Game object.
  new result
  var setsString: string
  discard line.scanf("Game $i: $+$.", result.id, setsString)
  for setString in setsString.split(';'):
    var cubeSet: CubeSet
    for cubeString in setString.split(','):
      var count: int
      var colorString: string
      discard cubeString.strip().scanf("$i $w", count, colorString)
      cubeSet[parseEnum[Color](colorString)] = count
    result.sets.add cubeSet

# Build the list of games.
var games: seq[Game]
for line in lines("p02.data"):
  if line.len > 0:
    games.add newGame(line)


### Part 1 ###

const Max = [Red: 12, Green: 13, Blue: 14]  # Maximum number of cubes allowed.

func isPossible(game: Game): bool =
  ## return true if the game is possible.
  for cubeSet in game.sets:
    for color, count in cubeSet:
      if count > Max[color]:
        return false
  result = true

var idSum = 0
for game in games:
  if game.isPossible:
    idSum.inc game.id
echo "Part 1: ", idSum


### Part 2 ###

func power(game: Game): int =
  ### Return the power of a game.
  var min: CubeSet
  for cubeSet in game.sets:
    for color, count in cubeSet:
      if count > min[color]:
        min[color] = count
  result = min[Red] * min[Green] * min[Blue]

var powerSum = 0
for game in games:
  powerSum.inc game.power
echo "Part 2: ", powerSum

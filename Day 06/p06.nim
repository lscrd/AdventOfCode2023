import std/[math, sequtils, strutils]

# If "t" is the race duration and "d" the current maximum distance, we have
# to find a value "x" such that "x * (t - x) > d" or  "x² - tx + d < 0".
# The discrimimant or this inequation is "delta = t² - 4d" and the roots are:
#   r1 = (t - sqrt(delta)) / 2
#   r2 = (t + sqrt(delta)) / 2
# For "x" in [0, r1] or "x" in [r2, t], the distance is less than or equal to "d".
# As we want integer values for "x", the limits to get a distance greater than "d" are:
#   t1 = floor(r1 + 1)
#   t2 = ceil(r2 - 1)
# And thus the number of ways to get such a distance is "t2 - t1 + 1".


let data = readLines("p06.data", 2)

func count(t, d: float): int =
  ## Return the number of possibilities to get a distance longer
  ## than "d" for a race time of "t".
  let s = sqrt(t * t - 4 * d)
  let t1 = floor((t - s) * 0.5 + 1)
  let t2 = ceil((t + s) * 0.5 - 1)
  result = int(t2 - t1 + 1)


### Part 1 ###

let times =  map(data[0].splitWhitespace()[1..^1], parseInt)
let distances = map(data[1].splitWhitespace()[1..^1], parseInt)

var result = 1
for i in 0..times.high:
  result *= count(times[i].toFloat, distances[i].toFloat)
echo "Part 1: ", result


### Part 2 ###
let time = data[0].splitWhitespace()[1..^1].join().parseInt()
let distance = data[1].splitWhitespace()[1..^1].join().parseInt()

echo "Part 2: ", count(time.toFloat, distance.toFloat)

import std/[algorithm, sequtils, strscans, strutils]

type
  MapType {.pure.} = enum
                     SeedToSoil = "seed-to-soil"
                     SoilToFertilizer = "soil-to-fertilizer"
                     FertilizerToWater = "fertilizer-to-water"
                     WaterToLight = "water-to-light"
                     LightToTemperature = "light-to-temperature"
                     TemperatureToHumidity = "temperature-to-humidity"
                     HumidityToLocation = "humidity-to-location"

  Range = Slice[int]
  Ranges = seq[Range]

  # Mapping of a source range to a destination range.
  Map = seq[tuple[srcRange, destRange: Range]]


var seedValues: seq[int]        # List of seed values.
var maps: array[MapType, Map]

# Parse the data file.
var mapType: MapType
for line in lines("p05.data"):
  var values: string
  var mapName: string
  if line.len == 0: continue
  if line.scanf("seeds: $+$.", values):
    seedValues = map(values.split(' '), parseInt)
  elif line.scanf("$+ map:", mapName):
    mapType = parseEnum[MapType](mapName)
  elif line.scanf("$+$.", values):
    let fields = map(values.split(' '), parseInt)
    maps[mapType].add (fields[1]..(fields[1]+fields[2]-1), fields[0]..(fields[0]+fields[2]-1))
  else:
    discard


### Part 1 ###

func value(m: Map; n: int): int =
  ## Return the value associated to input "n" using given map and part 1 rules.
  for (src, dest) in m:
    if n in src:
      return dest.a + (n - src.a)
  result = n

# Find the lowest location value.
var lowestLoc = int.high
for seed in seedValues:
  let loc = maps[HumidityToLocation].value(
              maps[TemperatureToHumidity].value(
                maps[LightToTemperature].value(
                  maps[WaterToLight].value(
                    maps[FertilizerToWater].value(
                      maps[SoilToFertilizer].value(
                        maps[SeedToSoil].value(seed)))))))
  if loc < lowestLoc:
    lowestLoc = loc

echo "Part 1: ", lowestLoc


### Part 2 ###

func cmp(x, y: Range): int =
  ## Range comparison function.
  result = cmp(x.a, y.a)
  if result == 0:
    result = cmp(x.b, y.b)

func values(map: Map; ranges: Ranges): Ranges =
  ## Return the ranges associated to input "ranges" using givent map and part 2 rules.
  for src in ranges:
    var first = src.a
    let last = src.b
    for (s, d) in map:
      if first < s.a:
        if last < s.a:
          result.add first..last
          first = last + 1
          break
        # Split.
        result.add first..(s.a - 1)
        first = s.a
      if first <= s.b:
        # First is in source range.
        let i = first - s.a
        if last <= s.b:
          result.add (d.a + i)..(d.a + + i + last - first)
          first = last + 1
          break
        # Split.
        result.add (d.a + i)..d.b
        first = s.b + 1
    # Add remaining range, if any.
    if first <= last:
      result.add first..last

# Sort the list of ranges for each map.
for mt in MapType.low..MapType.high:
  maps[mt].sort()

# Build the seed ranges from seed values.
var seedRanges: Ranges
for i in countup(0, seedValues.high, 2):
  let firstSeed = seedValues[i]
  seedRanges.add firstSeed..(firstSeed + seedValues[i + 1] - 1)

# Find the location ranges.
let locRanges = maps[HumidityToLocation].values(
                  maps[TemperatureToHumidity].values(
                    maps[LightToTemperature].values(
                      maps[WaterToLight].values(
                        maps[FertilizerToWater].values(
                          maps[SoilToFertilizer].values(
                            maps[SeedToSoil].values(seedRanges)))))))

# Find the lowest location value.
lowestLoc = int.high
for locRange in locRanges:
  if locRange.a < lowestLoc:
    lowestLoc = locRange.a

echo "Part 2: ", lowestLoc

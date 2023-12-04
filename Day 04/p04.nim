import std/[math, sequtils, strscans, strutils]

type Value = 0..99     # Possible values on cards.

# Scores of cards, i.e. number of winning values in owned values.
var cardScores: seq[Natural]

# Build card scores.
for line in lines("p04.data"):
  var num: int
  var winningStr, ownedStr: string
  if line.scanf("Card $s$i: $+ | $+$.", num, winningStr, ownedStr):
    var winning, owned: set[Value]
    for s in winningStr.split(' '):
      if s.len > 0:
        winning.incl parseInt(s)
    for s in ownedStr.split(' '):
      if s.len > 0:
        owned.incl parseInt(s)
    cardScores.add card(winning * owned)


### Part 1 ###
var points = 0
for cardScore in cardScores:
  if cardScore != 0:
    points += 1 shl (cardScore - 1)
echo "Part 1: ", points


### Part 2 ###
var cardCounts = repeat(1, cardScores.len)  # Count of cards for each card number.
for cardIndex, cardScore in cardScores:
  # Make copies.
  for n in 1..cardScore:
    cardCounts[cardIndex + n] += cardCounts[cardIndex]
echo "Part 2: ", sum(cardCounts)

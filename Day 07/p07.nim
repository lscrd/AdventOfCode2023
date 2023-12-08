import std/[algorithm, strscans, sugar, tables]

# We represent the cards by a value from 0 to 12. This allows direct
# comparison without using a custom comparison function.
#
# Another solution could be to represent cards with an enumeration type
# (different for each part) but to avoid defining two procedures to build
# the data representation, we had either to define a generic function or
# to use inheritance.

type
  CardValue = 0..12
  HandType {.pure.} = enum HighCard
                           OnePair
                           TwoPairs
                           ThreeOfAKind
                           FullHouse
                           FourOfAKind
                           FiveOfAKind
  Hand = array[5, CardValue]
  HandAndBid = tuple[hand: Hand; bid: int]

const
  # Mappings from card character to card value.
  Values1 = collect(for i, c in "23456789TJQKA": {c: i})  # For part 1.
  Values2 = collect(for i, c in "J23456789TQKA": {c: i})  # For part 2.
  Joker = Values2['J']   # Joker value in part 2.

var
  input: seq[HandAndBid]
  result: int

proc readHandsAndBids(filename: string; values: Table[char, int]): seq[HandAndBid] =
  ## Read the hands and the associated bids.
  for line in lines(filename):
    var handStr: string
    var bid: int
    if line.scanf("$+ $i", handStr, bid):
      var hand: Hand
      for i, c in handStr:
        if c notin values:
          raise newException(ValueError, "Illegal card: " & c)
        hand[i] = values[c]
      result.add (hand, bid)



### Part 1 ###

func handType1(hand: Hand): HandType =
  ## Return the hand type of a hand using part 1 rules.
  var hand = hand.toCountTable
  hand.sort()
  result = HighCard
  for count in hand.values:
    case count
    of 1:
      return
    of 2:
      if result == ThreeOfAKind: return FullHouse
      if result == OnePair: return TwoPairs
      result = OnePair
    of 3:
      result = ThreeOfAKind
    of 4:
      return FourOfAKind
    of 5:
      return FiveOfAKind
    else:
      raise newException(ValueError, "Internal error")


func cmp1(hb1, hb2: HandAndBid): int =
  ## Compare two hands (and associated bid) using part 1 rules.
  let ht1 = hb1.hand.handType1
  let ht2 = hb2.hand.handType1
  result = cmp(ht1, ht2)
  if result == 0:
    # Same hand type. Compare cards.
    for i in 0..4:
      result = cmp(hb1.hand[i], hb2.hand[i])
      if result != 0: return


input = readHandsAndBids("p07.data", Values1)
input.sort(cmp1)    # Sort the hands with associated bids using rules 1.
result = 0
for i, hb in input:
  result += hb.bid * (i + 1)

echo "Part 1: ", result



### Part 2 ###

func handType2(hand: Hand): HandType =
  ## Return the hand type of a hand using part 2 rules.
  var hand = hand.toCountTable
  hand.sort()
  result = HighCard
  var jokerCount = 0
  for card, count in hand.pairs:
    if card == Joker:
      # Ignore jokers for now.
      jokerCount = count
      continue
    case count
    of 1: discard
    of 2: result = case result
                   of ThreeOfAKind: FullHouse
                   of OnePair: TwoPairs
                   else: OnePair
    of 3: result = ThreeOfAKind
    of 4: result = FourOfAKind
    of 5: result = FiveOfAKind
    else:
      raise newException(ValueError, "Internal error")

  # Take in account the jokers.
  case jokerCount
  of 1: result = case result
                 of HighCard: OnePair
                 of OnePair: ThreeOfAKind
                 of TwoPairs: FullHouse
                 of ThreeOfAKind: FourOfAKind
                 of FourOfAKind: FiveOfAKind
                 else: result
  of 2: result = case result
                 of HighCard: ThreeOfAKind
                 of OnePair: FourOfAKind
                 of ThreeOfAKind: FiveOfAKind
                 else: result
  of 3: result = case result
                 of HighCard: FourOfAKind
                 of OnePair: FiveOfAKind
                 else: result
  of 4, 5: result = FiveOfAKind
  else: discard


func cmp2(hb1, hb2: HandAndBid): int =
  ## Compare two hands (and associated bid) using part 2 rules.
  let ht1 = hb1.hand.handType2
  let ht2 = hb2.hand.handType2
  result = cmp(ht1, ht2)
  if result == 0:
    # Same hand type. Compare cards.
    for i in 0..4:
      result = cmp(hb1.hand[i], hb2.hand[i])
      if result != 0: return


input = readHandsAndBids("p07.data", Values2)
input.sort(cmp2)    # Sort the hands with associated bids using rules 2.
result = 0
for i, hb in input:
  result += hb.bid * (i + 1)
echo "Part 2: ", result

import std/[algorithm, strscans, sugar, tables]

type
  Card = char
  HandType {.pure.} = enum HighCard
                           OnePair
                           TwoPairs
                           ThreeOfAKind
                           FullHouse
                           FourOfAKind
                           FiveOfAKind
  Hand = array[5, Card]
  HandAndBid = tuple[hand: Hand; bid: int]

# Read the hands and the associated bids.
var input: seq[HandAndBid]
for line in lines("p07.data"):
  var handStr: string
  var bid: int
  if line.scanf("$+ $i", handStr, bid):
    var hand: Hand
    for i, c in handStr:
      doAssert c in "23456789TJQKA"
      hand[i] = c
    input.add (hand, bid)



### Part 1 ###

# Table used for comparison of cards.
const Values1 = collect(for i, c in "23456789TJQKA": {c: i})


func cmp1(card1, card2: Card): int =
  ## Compare two cards.
  cmp(Values1[card1], Values1[card2])


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
      result = cmp1(hb1.hand[i], hb2.hand[i])
      if result != 0: return

# Compute result.
input.sort(cmp1)    # Sort the hands with associated bids.
var result = 0
for i, hb in input:
  result += hb.bid * (i + 1)
echo "Part 1: ", result



### Part 2 ###

# Table used for comparison of cards.
const Values2 = collect(for i, c in "J23456789TQKA": {c: i})


func cmp2(card1, card2: Card): int =
  ## Compare two cards.
  cmp(Values2[card1], Values2[card2])


func handType2(hand: Hand): HandType =
  ## Return the hand type of a hand using part 2 rules.
  var hand = hand.toCountTable
  hand.sort()
  result = HighCard
  var jokerCount = 0
  for card, count in hand.pairs:
    if card == 'J':
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
      result = cmp2(hb1.hand[i], hb2.hand[i])
      if result != 0: return

# Compute result.
input.sort(cmp2)    # Sort the hands with associated bids.
result = 0
for i, hb in input:
  result += hb.bid * (i + 1)
echo "Part 2: ", result

class HandEvalTest
  require 'video_poker'
  require 'cards'
 
  include VideoPoker

  def initialize
    deck = Cards::Deck.new
    deck.wildcard = Cards::Card::TWO
    @evaluator = HandEvaluator.new(deck)
  end

  def run
    #
    # create hands in reverse hand value order and ensure that each is_ method
    # returns the correct boolean
    # NATURAL_ROYAL_FLUSH=1
    # FOUR_WILDCARDS_W_ACE=2
    # FOUR_WILDCARDS=3
    # FIVE_KIND_ACES=4
    # FIVE_KIND_3_5=5
    # WILD_ROYAL_FLUSH=6
    # FIVE_KIND_6_K=7
    # STRAIGHT_FLUSH=8
    # FOUR_KIND=9
    # FULL_HOUSE=10
    # FLUSH=11
    # STRAIGHT=12
    # THREE_KIND=13
    # NO_HAND=14
    #

    check("JS AC 4D 8H 2D", Hands::NO_HAND, "NO HAND")
    check("2H 4H 6D 8H 10H", Hands::NO_HAND, "NO HAND")

    check("JS JC JD 8H 4D", Hands::THREE_KIND, "NATURAL THREE_KIND")
    check("JS JC 2D 8H 4D", Hands::THREE_KIND, "THREE_KIND WITH 1 WILD")
    check("JS 2C 2D 8H 4D", Hands::THREE_KIND, "THREE_KIND WITH 2 WILD")

    check("4S 6C 3D 5H 7S", Hands::STRAIGHT, "NATURAL STRAIGHT")
    check("KS QC 10D JH AS", Hands::STRAIGHT, "NATURAL STRAIGHT WITH ACE")
    check("KS 2C 10D JH AS", Hands::STRAIGHT, "STRAIGHT WITH 1 WILD")
    check("4S 2C 2D 8H 7S", Hands::STRAIGHT, "STRAIGHT WITH 2 WILD")

    check("4S 8S 7S QS AS", Hands::FLUSH, "NATURAL FLUSH")
    check("4S 8S 2H QS AS", Hands::FLUSH, "FLUSH WITH 1 WILD")
    check("2D 8S 2H QS AS", Hands::FLUSH, "FLUSH WITH 2 WILD")

    check("4D 4S 9H 4C 9D", Hands::FULL_HOUSE, "NATURAL FULL_HOUSE")
    check("4D 2S 9H 4C 9D", Hands::FULL_HOUSE, "FULL_HOUSE WITH 1 WILD")
    check("4D 2S 2H 4C 9D", Hands::FOUR_KIND, "FULL_HOUSE WITH 2 WILD IS FOUR_KIND")

    check("4D 4S 9H 4C 4H", Hands::FOUR_KIND, "NATURAL FOUR_KIND")
    check("4D 4S 9H 2C 4H", Hands::FOUR_KIND, "FOUR_KIND WITH 1 WILD")
    check("4D 4S 9H 2C 2H", Hands::FOUR_KIND, "FOUR_KIND WITH 2 WILD")
    check("2D 10S 4H 2C 2H", Hands::FOUR_KIND, "FOUR_KIND WITH 3 WILD")

    check("5H 6H 9H 7H 8H", Hands::STRAIGHT_FLUSH, "NATURAL STRAIGHT FLUSH")
    check("5H 6H 2D 7H 8H", Hands::STRAIGHT_FLUSH, "STRAIGHT FLUSH WITH 1 WILD")
    check("7C 9C 2D 8C 2H", Hands::STRAIGHT_FLUSH, "STRAIGHT FLUSH WITH 2 WILD")

    check("6C 6S 6D 6H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 1 WILD (6)")
    check("6C 6S 2D 6H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 2 WILD (6)")
    check("KC KS 2D KH 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 2 WILD (K)")
    check("9C 2S 2D 9H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 3 WILD (9)")

    check("10C JC AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 1 WILD")
    check("10C 2D AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 2 WILD")
    check("2C 2D AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 3 WILD")

    check("3C 3S 3D 3H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 1 WILD (3)")
    check("3C 3S 2D 3H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 2 WILD (3)")
    check("5C 5S 2D 5H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 2 WILD (5)")
    check("4C 2S 2D 4H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 3 WILD (4)")

  end

  def check(cards, should_be, this_hand)
    hand = h(cards.split(' '))
    res = @evaluator.evaluate(hand)
    raise "#{hand} should be #{this_hand} but is #{res}" if res != should_be
    puts "#{hand} is #{this_hand}"
  end

  def h(cards)
    Cards::Cards.make(*cards)
  end
end

he = HandEvalTest.new
he.run

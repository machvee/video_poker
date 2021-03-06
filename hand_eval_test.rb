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
    check_no_hand
    check_three_of_a_kind
    check_straight
    check_flush
    check_full_house
    check_four_of_a_kind
    check_straight_flush
    check_five_of_a_kind_6_K
    check_wild_royal_flush
    check_five_of_a_kind_3_5
    check_five_of_a_kind_aces
    check_four_wildcards
    check_four_wildcards_with_ace
    check_natural_royal_flush
  end

  private 

  def check_no_hand
    check("JS AC 4D 8H 2D", Hands::NO_HAND, "NO HAND")
    check("2H 4H 6D 8H 10H", Hands::NO_HAND, "NO HAND")
    check("10H 10D 8D 9H QH", Hands::NO_HAND, "NO HAND")
  end

  def check_three_of_a_kind
    check("JS JC JD 8H 4D", Hands::THREE_KIND, "NATURAL THREE_KIND")
    check("JS JC 2D 8H 4D", Hands::THREE_KIND, "THREE_KIND WITH 1 WILD")
    check("JS 2C 2D 8H 4D", Hands::THREE_KIND, "THREE_KIND WITH 2 WILD")
  end

  def check_straight
    check("4S 6C 3D 5H 7S", Hands::STRAIGHT, "NATURAL STRAIGHT")
    check("KS QC 10D JH AS", Hands::STRAIGHT, "NATURAL STRAIGHT WITH ACE")
    check("KS 2C 10D JH AS", Hands::STRAIGHT, "STRAIGHT WITH 1 WILD")
    check("4S 2C 2D 8H 7S", Hands::STRAIGHT, "STRAIGHT WITH 2 WILD")
    check("10H JH QD KH AH", Hands::STRAIGHT, "STRAIGHT")
  end

  def check_flush
    check("4S 8S 7S QS AS", Hands::FLUSH, "NATURAL FLUSH")
    check("4S 8S 2H QS AS", Hands::FLUSH, "FLUSH WITH 1 WILD")
    check("2D 8S 2H QS AS", Hands::FLUSH, "FLUSH WITH 2 WILD")
  end

  def check_full_house
    check("4D 4S 9H 4C 9D", Hands::FULL_HOUSE, "NATURAL FULL_HOUSE")
    check("4D 2S 9H 4C 9D", Hands::FULL_HOUSE, "FULL_HOUSE WITH 1 WILD")
    check("4D 2S 2H 4C 9D", Hands::FOUR_KIND, "FULL_HOUSE WITH 2 WILD IS FOUR_KIND")
  end

  def check_four_of_a_kind
    check("4D 4S 9H 4C 4H", Hands::FOUR_KIND, "NATURAL FOUR_KIND")
    check("4D 4S 9H 2C 4H", Hands::FOUR_KIND, "FOUR_KIND WITH 1 WILD")
    check("4D 4S 9H 2C 2H", Hands::FOUR_KIND, "FOUR_KIND WITH 2 WILD")
    check("2D 10S 4H 2C 2H", Hands::FOUR_KIND, "FOUR_KIND WITH 3 WILD")
  end

  def check_straight_flush
    check("5H 6H 9H 7H 8H", Hands::STRAIGHT_FLUSH, "NATURAL STRAIGHT FLUSH")
    check("5H 6H 2D 7H 8H", Hands::STRAIGHT_FLUSH, "STRAIGHT FLUSH WITH 1 WILD")
    check("7C 9C 2D 8C 2H", Hands::STRAIGHT_FLUSH, "STRAIGHT FLUSH WITH 2 WILD")
  end

  def check_five_of_a_kind_6_K
    check("6C 6S 6D 6H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 1 WILD (6)")
    check("6C 6S 2D 6H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 2 WILD (6)")
    check("KC KS 2D KH 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 2 WILD (K)")
    check("9C 2S 2D 9H 2H", Hands::FIVE_KIND_6_K, "FIVE KIND 6 THRU K WITH 3 WILD (9)")
  end

  def check_wild_royal_flush
    check("10C JC AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 1 WILD")
    check("10C 2D AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 2 WILD")
    check("2C 2D AC 2H QC", Hands::WILD_ROYAL_FLUSH, "WILD ROYAL FLUSH WITH 3 WILD")
  end

  def check_five_of_a_kind_3_5
    check("3C 3S 3D 3H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 1 WILD (3)")
    check("3C 3S 2D 3H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 2 WILD (3)")
    check("5C 5S 2D 5H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 2 WILD (5)")
    check("4C 2S 2D 4H 2H", Hands::FIVE_KIND_3_5, "FIVE KIND 3 THRU 5 WITH 3 WILD (4)")
  end

  def check_five_of_a_kind_aces
    check("AC AS AD AH 2H", Hands::FIVE_KIND_ACES, "FIVE KIND ACES WITH 1 WILD")
    check("AC AS 2S AH 2D", Hands::FIVE_KIND_ACES, "FIVE KIND ACES WITH 2 WILD")
    check("AC 2S 2D AH 2C", Hands::FIVE_KIND_ACES, "FIVE KIND ACES WITH 3 WILD")
  end

  def check_four_wildcards
    check("2H 2S 2D 3H 2C", Hands::FOUR_WILDCARDS, "FOUR WILD CARDS AND 3")
    check("2H 2S 2D KH 2C", Hands::FOUR_WILDCARDS, "FOUR WILD CARDS AND K")
    check("2H 2S 2D 7H 2C", Hands::FOUR_WILDCARDS, "FOUR WILD CARDS AND 7")
  end

  def check_four_wildcards_with_ace
    check("2H 2S 2D AH 2C", Hands::FOUR_WILDCARDS_W_ACE, "FOUR WILD CARDS WITH ACE")
  end

  def check_natural_royal_flush
    check("10H JH QH KH AH", Hands::NATURAL_ROYAL_FLUSH, "NATURAL ROYAL FLUSH")
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
puts ""
puts "ALL test completed successfully"
